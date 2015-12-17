#!/bin/bash
if [[ $1 == "" ]]; then
  echo please pass video file as first argument
  exit 1
fi
video_file=$1
shift
video_file_basename=`basename ${video_file}`
tmpdir=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
echo 'tmpdir'
echo $tmpdir
ffmpeg -i "$video_file" -vf fps=1 $tmpdir/${video_file_basename}_%03d.jpg
convert $tmpdir/${video_file_basename}_*.jpg -resize 50% GIF:- | gifsicle --delay=50 --loop --optimize=2 --colors=256 --multifile - > ${video_file}.gif
