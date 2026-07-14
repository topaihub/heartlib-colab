# heartlib-colab

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/topaihub/heartlib-colab/blob/main/heartlib_colab.ipynb)

这是一个给 Google Colab 准备的独立项目，用来快速跑通 `HeartMuLa/heartlib` 的音乐生成示例。

## 目录

- `heartlib_colab.ipynb`: 可直接上传到 Colab 的 notebook
- `pyproject.toml`: `uv` 项目配置
- `scripts/setup_colab.sh`: Colab 环境初始化脚本
- `scripts/run_generation.py`: 一键生成脚本
- `inputs/lyrics.txt`: 默认歌词
- `inputs/tags.txt`: 默认 tags

## 用法

## Colab 地址

- Google Colab: https://colab.research.google.com/
- 新建 notebook: https://colab.research.google.com/#create=true

### 方式 1：直接用 notebook

1. 上传 `heartlib_colab.ipynb` 到 Colab。
2. 在 Colab 里开启 GPU。
3. 依次运行 notebook 的所有单元。
4. notebook 会自动从 GitHub clone `topaihub/heartlib-colab`。

最短路径：

1. 打开 `https://colab.research.google.com/`
2. 选择 `Upload`
3. 上传 `heartlib_colab.ipynb`
4. 在 `Runtime -> Change runtime type -> Hardware accelerator` 里选择 `GPU`
5. 运行 notebook，第一格会自动 clone 项目到 `/content/heartlib-colab`

### 方式 2：手动执行

在 Colab 里：

```bash
!bash scripts/setup_colab.sh
!uv run python scripts/run_generation.py --model-path /content/ckpt --lazy-load true
```

## 说明

- 默认会 clone 官方 `heartlib` 仓库到 `/content/heartlib`。
- 默认从 Hugging Face 下载：
  - `HeartMuLa/HeartMuLaGen`
  - `HeartMuLa/HeartMuLa-oss-3B`
  - `HeartMuLa/HeartCodec-oss`
- 生成结果默认写到 `/content/output.mp3`。
- Colab 免费 GPU 不稳定，建议先用较短音频测试，例如 `--max-audio-length-ms 30000`。
