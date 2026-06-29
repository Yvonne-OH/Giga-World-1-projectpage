#!/bin/bash
set -e

ROOT="/Users/zhanqianwu/Documents/工作/工作文档/Giga/Giga_world_1/github_page"
SRC="$ROOT/video/model_trans/agi/episode_000014.mp4"
OUT="$ROOT/video/model_trans/agi/episode_000014_90s_125s_10fps_annotated.mp4"
TMP_DIR="$ROOT/video/model_trans/agi/.episode_000014_frames"
ANNOTATED_DIR="$ROOT/video/model_trans/agi/.episode_000014_annotated_frames"

rm -rf "$TMP_DIR" "$ANNOTATED_DIR"
mkdir -p "$TMP_DIR" "$ANNOTATED_DIR"

ffmpeg -y -ss 00:01:30 -to 00:02:05 -i "$SRC" \
  -vf fps=10 "$TMP_DIR/frame_%05d.png"

python3 - <<'PY'
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path('/Users/zhanqianwu/Documents/工作/工作文档/Giga/Giga_world_1/github_page')
src_dir = root / 'video/model_trans/agi/.episode_000014_frames'
out_dir = root / 'video/model_trans/agi/.episode_000014_annotated_frames'
font_path = '/System/Library/Fonts/Helvetica.ttc'
font = ImageFont.truetype(font_path, 28)
small_font = ImageFont.truetype(font_path, 24)

fps = 10
for idx, frame_path in enumerate(sorted(src_dir.glob('frame_*.png'))):
    img = Image.open(frame_path).convert('RGB')
    draw = ImageDraw.Draw(img, 'RGBA')
    seconds = idx / fps
    minutes = int(seconds // 60)
    secs = seconds % 60
    time_text = f'TIME: {minutes:02d}:{secs:05.2f}'
    frame_text = f'FRAME: {idx}'

    draw.rounded_rectangle((12, 12, 330, 106), radius=10, fill=(0, 0, 0, 155))
    draw.text((30, 28), time_text, font=font, fill=(255, 255, 255, 255))
    draw.text((30, 66), frame_text, font=small_font, fill=(255, 255, 255, 255))
    img.save(out_dir / frame_path.name, quality=95)
PY

ffmpeg -y -framerate 10 -i "$ANNOTATED_DIR/frame_%05d.png" \
  -c:v libx264 -preset fast -crf 18 -pix_fmt yuv420p -movflags +faststart "$OUT"

rm -rf "$TMP_DIR" "$ANNOTATED_DIR"

echo "--- DONE ---"
ls -la "$OUT"
