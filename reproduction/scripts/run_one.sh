#!/bin/bash
# 单次运行：run_one.sh <数据集> <噪声类型 sym|asym> <噪声率> <种子> [额外的 Dassl 配置覆盖...]
# 数据集：caltech101 / dtd / oxford_flowers。先 conda activate nlprompt。
# 超参按论文 6.3 节和 configs/trainers/NLPrompt/rn50.yaml：CLIP RN50，16-shot，200 轮，SGD + 余弦退火，
# 学习率只取 0.002 一个（官方脚本 scripts/nlprompt/main.sh 默认扫 0.001 / 0.0006 / 0.0007）；
# OT 熵正则 REG_E 用 train.py 的默认值 0.01。NUM_WORKERS 从配置里的 0 改成 4，只为加快读图。
set -e
REPO=$(cd "$(dirname "$0")/../.." && pwd)
DATA=${DATA:-$REPO/data}
OUT_ROOT=${OUT_ROOT:-$REPO/output}
DS=$1; TYPE=$2; RATE=$3; SEED=$4; shift 4
case $DS in
  caltech101) NC=100 ;;
  dtd) NC=47 ;;
  oxford_flowers) NC=102 ;;
  *) echo "未知数据集 $DS"; exit 1 ;;
esac
OUT=$OUT_ROOT/repro/$DS/${TYPE}_${RATE}/seed$SEED
if grep -q "accuracy" "$OUT/log.txt" 2>/dev/null && grep -q "Elapsed" "$OUT/log.txt" 2>/dev/null; then
  echo "跳过（已完成）$OUT"; exit 0
fi
cd "$REPO"
python train.py \
  --root "$DATA" \
  --seed $SEED \
  --trainer NLPrompt \
  --dataset-config-file configs/datasets/$DS.yaml \
  --config-file configs/trainers/NLPrompt/rn50.yaml \
  --output-dir "$OUT" \
  DATASET.NUM_SHOTS 16 \
  DATASET.NOISE_RATE $RATE \
  DATASET.NOISE_TYPE $TYPE \
  DATASET.num_class $NC \
  DATASET.REG_E 0.01 \
  OPTIM.LR 0.002 \
  DATALOADER.NUM_WORKERS 4 \
  "$@"
