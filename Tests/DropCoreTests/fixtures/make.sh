#!/bin/zsh
# Makes the test files with ffmpeg. They are committed because they are small; run this only to
# change them, and check the tests still read what this script meant.
set -euo pipefail
cd "${0:A:h}"
ff=(ffmpeg -hide_banner -loglevel error -y)
tags=(setparams=color_primaries=bt709:color_trc=bt709:colorspace=bt709:range=tv)

# What Final Cut exports, small: ProRes 422 HQ, 25 fps, Rec. 709, 24-bit PCM stereo, a timecode track.
$ff -f lavfi -i "testsrc2=size=320x180:rate=25:duration=2,format=yuv422p10le,$tags" \
    -f lavfi -i "sine=frequency=440:sample_rate=48000:duration=2" -ac 2 \
    -c:v prores_ks -profile:v 3 -c:a pcm_s24le -timecode 01:00:00:00 prores-hq-320x180.mov

# Portrait with mono sound: the box turns, and mono comes out as stereo.
$ff -f lavfi -i "testsrc2=size=180x320:rate=30:duration=1,format=yuv422p10le,$tags" \
    -f lavfi -i "sine=frequency=330:sample_rate=48000:duration=1" -ac 1 \
    -c:v prores_ks -profile:v 2 -c:a pcm_s16le prores-portrait-mono.mov

# Larger than 4K: scaled into the 3840x2160 box. Five frames of Proxy keep it small.
$ff -f lavfi -i "testsrc2=size=5120x2880:rate=25:duration=0.2,format=yuv422p10le,$tags" \
    -c:v prores_ks -profile:v 0 prores-proxy-5k.mov

# A codec the Mac cannot decode, in a container it can open.
$ff -f lavfi -i "testsrc2=size=320x180:rate=25:duration=1" -c:v ffv1 ffv1.mov

# Not a video at all.
printf 'Folge 123: Shownotes\n' > not-a-video.mov
ls -la
