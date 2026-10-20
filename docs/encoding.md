# The encoding

What ProRes Drop makes of a file, why, and what it measured. The numbers live in
`Sources/DropCore/Plan.swift` and `Transcoder.swift`; this page carries their reasons.

## Why this format

The server this app feeds (its encoder lives in the private `infra` repository,
`roles/encoder/files/video-encode`) encodes every upload into an HEVC ladder. Its 4K rung is x265
`slower` CRF 29 capped at 5 Mbit/s. Since 2026-10-20 the plan is that an HEVC 4K upload at
delivery size, at most about 6 Mbit/s, becomes the 4K file by remux; the server then encodes only
1080, 720 and H.264, and the 4K file is there within minutes instead of 27 or more. ProRes
uploads are allowed only up to one minute, because a minute is about 5 GB. ProRes Drop turns a
ProRes export into exactly that upload, on the Mac's media engine.

**The server's acceptance rule is not in `video-encode` yet** (2026-10-20). When it lands, check
this page against it: the bit-rate bound, whether audio counts, and what "delivery size" means
for a source that is not 16:9.

## What comes out

| | value | why |
|---|---|---|
| Video | HEVC Main 10, tagged `hvc1`, 4:2:0 10-bit | what the server's 4K rung is; `hvc1` plays in Safari and QuickTime, `hev1` does not |
| Size | the source's, scaled into 3840×2160 only when larger, never up; portrait turns the box | the server's `fit()`: the same rounding, so 4096×2160 becomes 3840×2024 on both sides |
| Frames | the source's frame rate and timestamps, every frame kept | a remux keeps them as they are |
| Rate | 5 Mbit/s average, at most 6 Mbit/s in any second, for 4K at 25 frames or more; smaller sources get their share by pixels × frame rate | lands at about 4.2 Mbit/s of video, see "Measured" |
| Key frames | every 4 seconds at most | seeking in a long file without spending many bits |
| Colour | the source's primaries, transfer and matrix, all three or none | Final Cut writes Rec. 709 (1-1-1); a missing tag is not invented |
| Audio | the first audio track, AAC-LC stereo 48 kHz 256 kbit/s; mono becomes two equal channels | the server takes `0:a:0`, and copies AAC into the top rung |
| Container | MP4, `moov` before `mdat` (fast start) | a browser plays before the whole file is there |
| Name | the source's name with `.mp4`; `Name 2.mp4` when taken | never overwrites, never the source itself |

Timecode and other tracks are dropped. A file appears in the destination folder only after it is
read back and checked (playable, `hvc1`, Main 10, index in front, the source's length within one
frame, audio where the source had some); until then it lives in a temporary folder on the same
disk.

## Why VideoToolbox with an average and a peak

VideoToolbox has no CRF. With an average alone it spends exactly that, on every source. A peak
limit (`DataRateLimits`) holds it well below the limit, with headroom for hard scenes. Measured on
the 60-second 4K25 sample below, whole file with audio:

| average | peak, per second | file Mbit/s |
|---|---|---|
| 4.5 | 5.0 | 3.76 |
| 5.0 | 5.5 over 2 s | 4.11 |
| **5.0** | **6.0** | **4.46** |
| 4.5 | none | 4.76 |
| 6.0 | none | 6.26 |

The chosen pair lands at or below 5 Mbit/s and never above 6 in any second. Constant quality
(`kVTCompressionPropertyKey_Quality`) with the same peak behaved the same way on these samples and
gives no control over the average, so the app does not use it.

## Measured

On an Apple M2 Max, macOS 26.5.1, 2026-10-20, with `bin/test-encode` (synthetic 4K25 ProRes 422
HQ, 60 s, 788 Mbit/s, testsrc2 with grain, Rec. 709, PCM stereo, timecode):

- **20.4 s for 60 s of 4K**, about 3× real time; the file has 4.46 Mbit/s (video 4.20, audio
  0.25), 33.4 MB.
- ffprobe: `hevc`, `hvc1`, `Main 10`, `yuv420p10le`, 3840×2160, 25/1, 1500 frames, bt709 ×3,
  60.000 s for video, audio and file; AAC LC 48 kHz stereo; boxes `ftyp moov mdat`.
- AVFoundation calls it playable and decodes its first and last frame; QuickTime Player opened it
  without an error.

Quality against x265 `slower` CRF 29 with `vbv-maxrate=5000:vbv-bufsize=10000` (what the server's
4K rung is meant to be), 10-second clips, against the ProRes source:

| clip | encoder | video Mbit/s | PSNR avg dB | SSIM | time for 10 s |
|---|---|---|---|---|---|
| testsrc2 + grain | VideoToolbox 5/6 | 4.20 | 37.07 | 0.938 | 4 s |
| testsrc2 + grain | x265 slower CRF 29 | 5.36 | 37.49 | 0.939 | 156 s |
| testsrc2, clean | VideoToolbox 5/6 | 4.19 | 36.72 | 0.980 | 5 s |
| testsrc2, clean | x265 slower CRF 29 | 5.36 | 38.76 | 0.986 | 97 s |

Both clear the server's floors (PSNR 34, SSIM 0.85) by far. Synthetic pictures are not real
footage: a real export decides whether the quality holds, and its numbers go here.

The M2 Max has two video encode engines; one file uses one. An M2 has one, so its time per file
should be close to this; measure it on the first real export from one.
