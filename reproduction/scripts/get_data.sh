#!/bin/bash
# 下载 Caltech101、DTD、Flowers102 到 $DATA（默认 <仓库>/data），目录结构按 CoOp 的 DATASETS.md。
set -e
REPO=$(cd "$(dirname "$0")/../.." && pwd)
DATA=${DATA:-$REPO/data}
mkdir -p "$DATA/_dl" && cd "$DATA"

# Caltech101：官方地址在我们的服务器上返回 403，改用 Hugging Face 上的同一个 caltech-101.zip
# （国内可设 HF_ENDPOINT=https://hf-mirror.com）
HF=${HF_ENDPOINT:-https://huggingface.co}
mkdir -p caltech-101
curl -L -C - --retry 20 -o _dl/caltech-101.zip "$HF/datasets/HuggingFaceM4/Caltech-101/resolve/main/caltech-101.zip"
(cd _dl && unzip -q -o caltech-101.zip && tar -xzf caltech-101/101_ObjectCategories.tar.gz -C ../caltech-101)

# DTD
mkdir -p dtd
curl -L -C - --retry 20 -o _dl/dtd.tar.gz https://www.robots.ox.ac.uk/~vgg/data/dtd/download/dtd-r1.0.1.tar.gz
tar -xzf _dl/dtd.tar.gz -C _dl && cp -r _dl/dtd/* dtd/

# Flowers102
mkdir -p oxford_flowers
curl -L -C - --retry 20 -o _dl/102flowers.tgz https://www.robots.ox.ac.uk/~vgg/data/flowers/102/102flowers.tgz
curl -L --retry 20 -o oxford_flowers/imagelabels.mat https://www.robots.ox.ac.uk/~vgg/data/flowers/102/imagelabels.mat
tar -xzf _dl/102flowers.tgz -C oxford_flowers

# CoOp 的划分文件在 Google Drive 上；连不上 Google Drive 的机器，在本地下好再传到对应目录
gd() { python -m gdown -q "https://drive.google.com/uc?id=$1" -O "$2" || echo "下载失败，请手动下载：https://drive.google.com/file/d/$1 → $2"; }
[ -f caltech-101/split_zhou_Caltech101.json ] || gd 1hyarUivQE36mY6jSomru6Fjd-JzwcCzN caltech-101/split_zhou_Caltech101.json
[ -f dtd/split_zhou_DescribableTextures.json ] || gd 1u3_QfB467jqHgNXC00UIzbLZRQCg2S7x dtd/split_zhou_DescribableTextures.json
[ -f oxford_flowers/split_zhou_OxfordFlowers.json ] || gd 1Pp0sRXzZFZq15zVOzKjKBu4A9i01nozT oxford_flowers/split_zhou_OxfordFlowers.json
[ -f oxford_flowers/cat_to_name.json ] || gd 1AkcxCXeK_RCGCEC_GvmWxjcjaNhu-at0 oxford_flowers/cat_to_name.json

echo "Caltech101 $(ls caltech-101/101_ObjectCategories | wc -l) 个文件夹，DTD $(ls dtd/images | wc -l) 类，Flowers102 $(ls oxford_flowers/jpg | wc -l) 张图"
