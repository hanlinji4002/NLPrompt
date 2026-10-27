#!/bin/bash
# 全部 18 个设定：3 个数据集 × {sym, asym} × {0.25, 0.5, 0.75}，默认只跑种子 1，同时跑 P 个（默认 2）。
# 每个运行会把训练集和测试集图片读进内存（Flowers 约 7–12GB），内存小的机器把 P 设成 1。
export REPO=$(cd "$(dirname "$0")/../.." && pwd)
P=${P:-2}
SEEDS=${SEEDS:-1}
mkdir -p "$REPO/output/stdout"
for DS in caltech101 dtd oxford_flowers; do
  for TYPE in sym asym; do
    for RATE in 0.25 0.5 0.75; do
      for SEED in $SEEDS; do
        echo "$DS $TYPE $RATE $SEED"
      done
    done
  done
done | xargs -P $P -L 1 bash -c '"$REPO/reproduction/scripts/run_one.sh" $0 $1 $2 $3 > "$REPO/output/stdout/$0_$1_$2_seed$3.log" 2>&1 && echo "完成 $0 $1 $2 seed$3" || echo "失败 $0 $1 $2 seed$3"'
echo ALL_DONE
