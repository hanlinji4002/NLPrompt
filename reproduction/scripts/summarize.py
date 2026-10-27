"""汇总每个设定最后一轮的测试精度，和论文表 1（RN50）的 NLPrompt 一行对比。

用法：
    python reproduction/scripts/summarize.py                      # 读 output/repro/
    python reproduction/scripts/summarize.py reproduction/results/logs --markdown
"""
import glob, os, re, statistics as st, sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
args = [a for a in sys.argv[1:] if not a.startswith("--")]
root = args[0] if args else os.path.join(REPO, "output", "repro")
markdown = "--markdown" in sys.argv

PAPER = {  # 论文表 1（RN50），3 个种子的均值
    "caltech101": {"sym": {0.25: 91.13, 0.5: 89.93, 0.75: 86.70}, "asym": {0.25: 91.17, 0.5: 89.27, 0.75: 81.07}},
    "dtd": {"sym": {0.25: 61.23, 0.5: 55.17, 0.75: 39.80}, "asym": {0.25: 60.60, 0.5: 50.80, 0.75: 28.37}},
    "oxford_flowers": {"sym": {0.25: 92.57, 0.5: 89.90, 0.75: 76.80}, "asym": {0.25: 93.40, 0.5: 81.10, 0.75: 55.33}},
}
NAME = {"caltech101": "Caltech101", "dtd": "DTD", "oxford_flowers": "Flowers102"}

rows, diffs = [], []
for ds in PAPER:
    for t in ("sym", "asym"):
        for r in (0.25, 0.5, 0.75):
            accs = []
            for log in sorted(glob.glob(f"{root}/{ds}/{t}_{r}/seed*/log.txt")):
                txt = open(log).read()
                m = re.findall(r"\* accuracy: ([\d.]+)%", txt)
                if m and "Elapsed" in txt:
                    accs.append(float(m[-1]))
            p = PAPER[ds][t][r]
            if accs:
                mu = st.mean(accs)
                diffs.append(mu - p)
                rows.append((NAME[ds], t, f"{int(r * 100)}%", len(accs), f"{mu:.2f}", f"{p:.2f}", f"{mu - p:+.2f}"))
            else:
                rows.append((NAME[ds], t, f"{int(r * 100)}%", 0, "—", f"{p:.2f}", "—"))

head = ("数据集 Dataset", "噪声 Noise", "噪声率 Rate", "种子数 Seeds", "复现 Ours", "论文 Paper", "差 Diff")
if markdown:
    print("| " + " | ".join(head) + " |")
    print("|" + "---|" * len(head))
    for row in rows:
        print("| " + " | ".join(str(x) for x in row) + " |")
else:
    for row in [head] + rows:
        print("".join(f"{str(x):<16}" for x in row))
if diffs:
    print(f"\n{len(diffs)} 个设定，复现 − 论文 平均 {st.mean(diffs):+.2f}，范围 {min(diffs):+.2f} ~ {max(diffs):+.2f}")
