# Use the official Ubuntu base image
FROM ubuntu:22.04

# Set environment variables to non-interactive to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install necessary packages
RUN apt-get update && \
    apt-get install -y \
        software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
        python3.10 \
        python3.10-venv \
        python3.10-distutils \
        python3-pip \
        wget \
        git \
        libgl1 \
        libglib2.0-0 \
        && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as the default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Create a virtual environment for MinerU
RUN python3 -m venv /opt/mineru_venv

# Activate the virtual environment and install necessary Python packages
RUN /bin/bash -c "source /opt/mineru_venv/bin/activate && \
    pip3 install --upgrade pip && \
    wget https://gitee.com/myhloli/MinerU/raw/master/requirements-docker.txt && \
    pip3 install -r requirements-docker.txt --extra-index-url https://wheels.myhloli.com -i https://mirrors.aliyun.com/pypi/simple && \
    pip3 install paddlepaddle-gpu==3.0.0b1 -i https://www.paddlepaddle.org.cn/packages/stable/cu118/"

# Copy the configuration file template and install magic-pdf latest
RUN /bin/bash -c "wget https://gitee.com/myhloli/MinerU/raw/master/magic-pdf.template.json && \
    cp magic-pdf.template.json /root/magic-pdf.json && \
    source /opt/mineru_venv/bin/activate && \
    pip3 install -U magic-pdf"

# Download models and update the configuration file
RUN /bin/bash -c "pip3 install modelscope && \
    wget https://gitee.com/myhloli/MinerU/raw/master/scripts/download_models.py && \
    python3 download_models.py && \
    sed -i 's|cpu|cuda|g' /root/magic-pdf.json"

# Correctly extract PaddleOCR models to parent directories
RUN mkdir -p /root/.paddleocr/whl/det/ch && \
    wget https://paddleocr.bj.bcebos.com/PP-OCRv4/chinese/ch_PP-OCRv4_det_infer.tar -O /root/.paddleocr/whl/det/ch/ch_PP-OCRv4_det_infer.tar && \
    tar -xf /root/.paddleocr/whl/det/ch/ch_PP-OCRv4_det_infer.tar -C /root/.paddleocr/whl/det/ch && \
    rm /root/.paddleocr/whl/det/ch/ch_PP-OCRv4_det_infer.tar && \
    mkdir -p /root/.paddleocr/whl/rec/ch && \
    wget https://paddleocr.bj.bcebos.com/PP-OCRv4/chinese/ch_PP-OCRv4_rec_infer.tar -O /root/.paddleocr/whl/rec/ch/ch_PP-OCRv4_rec_infer.tar && \
    tar -xf /root/.paddleocr/whl/rec/ch/ch_PP-OCRv4_rec_infer.tar -C /root/.paddleocr/whl/rec/ch && \
    rm /root/.paddleocr/whl/rec/ch/ch_PP-OCRv4_rec_infer.tar && \
    mkdir -p /root/.paddleocr/whl/cls && \
    wget https://paddleocr.bj.bcebos.com/dygraph_v2.0/ch/ch_ppocr_mobile_v2.0_cls_infer.tar -O /root/.paddleocr/whl/cls/ch_ppocr_mobile_v2.0_cls_infer.tar && \
    tar -xf /root/.paddleocr/whl/cls/ch_ppocr_mobile_v2.0_cls_infer.tar -C /root/.paddleocr/whl/cls && \
    rm /root/.paddleocr/whl/cls/ch_ppocr_mobile_v2.0_cls_infer.tar


# Set the entry point to activate the virtual environment and run the command line tool
ENTRYPOINT ["/bin/bash", "-c", "source /opt/mineru_venv/bin/activate && exec \"$@\"", "--"]
