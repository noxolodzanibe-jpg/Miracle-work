#!/usr/bin/env bash
set -euo pipefail
D="$1"; F="$D/fonts"
PF="$F/playfair-display-latin-400-normal.ttf"; PFI="$F/playfair-display-latin-400-italic.ttf"
PFB="$F/playfair-display-latin-600-normal.ttf"; SC="$F/pinyon-script-latin-400-normal.ttf"
BG=0x171310; CREAM=0xEFE6DA; GOLD=0xC9A96E
# real picture area of the upload, minus the app watermark at the bottom
SRC="crop=476:404:186:0"
GRADE="eq=saturation=0.9:contrast=1.03:gamma=1.0,colorbalance=rs=0.03:bs=-0.03:rh=0.02:bh=-0.02"

ffmpeg -y -v error -i "$D/me.mp4" -filter_complex "
[0:v]trim=0:2.36,setpts=PTS-STARTPTS,$SRC,$GRADE,scale=1188:-2:flags=lanczos,
 scale=w='trunc(1080*(1+0.05*t/2.36)/2)*2':h=-2:eval=frame,crop=1080:916,setsar=1[a_in];
color=$BG:s=1080x1920:r=30:d=2.36[a_bg];
[a_bg][a_in]overlay=0:502:shortest=1,
 drawtext=fontfile=$PF:text='N O X O L O   B E A U T Y   B I Z':fontcolor=$GOLD:fontsize=30:x=(w-tw)/2:y=400:alpha='min(1,t/0.5)',
 drawtext=fontfile=$PF:text='Beauty is a ritual,':fontcolor=$CREAM:fontsize=48:x=96:y=1470:alpha='min(1,max(0,(t-0.3)/0.4))',
 drawtext=fontfile=$PFI:text='not a routine.':fontcolor=$CREAM:fontsize=84:x=96:y=1530:alpha='min(1,max(0,(t-0.7)/0.4))'[A];

[0:v]trim=0.3:2.3,setpts=1.3*(PTS-STARTPTS),$SRC,$GRADE,split[b1][b2];
[b1]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=28,eq=brightness=-0.18:saturation=0.6[b_bg];
[b2]crop=300:184:300:220,scale=w='trunc(900*(1+0.06*t/2.6)/2)*2':h=-2:eval=frame:flags=lanczos,crop=900:552,
 pad=906:558:3:3:color=$GOLD@0.8[b_in];
[b_bg][b_in]overlay=(W-w)/2:700,trim=0:2.6,
 drawtext=fontfile=$PFB:text='THE GLOW':fontcolor=$CREAM:fontsize=96:x=90:y=330:alpha='min(1,t/0.5)',
 drawtext=fontfile=$PFB:text='IS IN THE DETAILS.':fontcolor=$CREAM:fontsize=80:x=90:y=440:alpha='min(1,max(0,(t-0.25)/0.5))',
 drawtext=fontfile=$SC:text='skin  ·  ritual  ·  confidence':fontcolor=0xE2C894:fontsize=76:x=w-tw-90:y=1330:alpha='min(1,max(0,(t-0.7)/0.5))',
 drawtext=fontfile=$PFI:text='Noxolo Beauty Biz':fontcolor=$CREAM:fontsize=44:x=(w-tw)/2:y=1650:alpha='min(1,max(0,(t-1.2)/0.5))',
 fade=t=out:st=2.1:d=0.5:color=$BG,setsar=1,fps=30[B];

[A][B]xfade=transition=fade:duration=0.4:offset=1.96,format=yuv420p,
 vignette=angle=PI/5[v];
[0:a]atrim=0:2.4,asetpts=PTS-STARTPTS,afade=t=in:d=0.08,afade=t=out:st=2.3:d=0.1,apad,atrim=0:4.56,loudnorm=I=-16:TP=-1.5[a]
" -map "[v]" -map "[a]" -c:v libx264 -crf 18 -preset slow -c:a aac -b:a 192k -ar 48000 -movflags +faststart "$D/noxolo_cinematic.mp4"
