import argparse
from pathlib import Path

import torch
from heartlib import HeartMuLaGenPipeline


def str2bool(value):
    if isinstance(value, bool):
        return value
    lowered = value.lower()
    if lowered in {"yes", "y", "true", "t", "1"}:
        return True
    if lowered in {"no", "n", "false", "f", "0"}:
        return False
    raise argparse.ArgumentTypeError(f"Boolean value expected. Got: {value}")


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model-path", default="/content/ckpt")
    parser.add_argument("--lyrics", default="/content/heartlib-colab/inputs/lyrics.txt")
    parser.add_argument("--tags", default="/content/heartlib-colab/inputs/tags.txt")
    parser.add_argument("--save-path", default="/content/output.mp3")
    parser.add_argument("--version", default="3B")
    parser.add_argument("--max-audio-length-ms", type=int, default=30000)
    parser.add_argument("--topk", type=int, default=50)
    parser.add_argument("--temperature", type=float, default=1.0)
    parser.add_argument("--cfg-scale", type=float, default=1.5)
    parser.add_argument("--lazy-load", type=str2bool, default=True)
    parser.add_argument("--mula-device", default="cuda")
    parser.add_argument("--codec-device", default="cuda")
    return parser.parse_args()


def main():
    args = parse_args()

    Path(args.save_path).parent.mkdir(parents=True, exist_ok=True)

    pipe = HeartMuLaGenPipeline.from_pretrained(
        args.model_path,
        device={
            "mula": torch.device(args.mula_device),
            "codec": torch.device(args.codec_device),
        },
        dtype={
            "mula": torch.bfloat16,
            "codec": torch.float32,
        },
        version=args.version,
        lazy_load=args.lazy_load,
    )

    with torch.no_grad():
        pipe(
            {
                "lyrics": args.lyrics,
                "tags": args.tags,
            },
            max_audio_length_ms=args.max_audio_length_ms,
            save_path=args.save_path,
            topk=args.topk,
            temperature=args.temperature,
            cfg_scale=args.cfg_scale,
        )

    print(f"Generated music saved to {args.save_path}")


if __name__ == "__main__":
    main()
