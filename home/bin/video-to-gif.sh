#!/bin/bash
# Need ffmpeg, imagemagick, gifsicle
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
ffmpeg -i "$video_file" -vf "scale=iw/3:ih/3" -pix_fmt rgb8 -r 5 -f gif - | gifsicle --optimize=3 > ${video_file}.gif
