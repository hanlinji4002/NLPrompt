#!/bin/bash
# 建环境。我们用的是 Python 3.10、PyTorch 2.4.0（CUDA 12.1），pip 走清华源（PIP_INDEX 可改）。
set -e
REPO=$(cd "$(dirname "$0")/../.." && pwd)
source "$(conda info --base)/etc/profile.d/conda.sh"
conda create -n nlprompt python=3.10 -y
conda activate nlprompt
PIP="pip install -i ${PIP_INDEX:-https://pypi.tuna.tsinghua.edu.cn/simple}"
$PIP torch==2.4.0 torchvision==0.19.0
cd "$REPO/Dassl.pytorch"
# 清华源没有 tb-nightly，换成 tensorboard（只用来写训练曲线）
grep -v tb-nightly requirements.txt > /tmp/nlprompt_requirements.txt
echo tensorboard >> /tmp/nlprompt_requirements.txt
$PIP -r /tmp/nlprompt_requirements.txt
# setup.py 会把 requirements.txt（含 tb-nightly）当作依赖；依赖上一步已装好，所以加 --no-deps
pip install --no-deps --no-build-isolation -e .
python -c "import torch, dassl, ot; print(torch.__version__, torch.cuda.is_available())"
