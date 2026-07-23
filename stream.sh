#!/bin/bash
# 📵 Zaro Live Stream Script
# Usage: bash stream.sh [youtube_url] [restream_key]
# Pushes YouTube video to Restream.io in 720p60

YOUTUBE_URL="${1:-https://youtu.be/UonrUJfMSWk}"
RESTREAM_KEY="${2:-re_12000328_event11d497e43c154270ae00c867bf7d2225}"
MAX_DURATION="${3:-21600}"  # default 6h (GitHub limit)
LOOP="${4:-true}"           # loop the video

RTMP_URL="rtmp://live.restream.io/live/${RESTREAM_KEY}"

echo "📵 Zaro Live Stream"
echo "════════════════════"
echo "📶 Source : $YOUTUBE_URL"
echo "👥 Key    : ${RESTREAM_KEY:0:20}..."
echo "⏹️  Codec  : H264 + AAC_192kbps"
echo "🎯 Output : 720p 60fps"
echo ""

cleanup() {
    ELAPSED=$(date +%s); ELAPSED=$((ELAPSED - START_TIME))
    echo ""
    echo "⏹️  Stream stopped. Total: ${ELAPSED}s"
    exit 0
}
trap cleanup SIGINT SIGTERM

START_TIME=$(date +%s)

if [ "$LOOP" = "true" ]; then
    LOOP_COUNT=0
    while true; do
        LOOP_COUNT=$((LOOP_COUNT + 1))
        NOW=$(date +%s)
        ELAPSED=$((NOW - START_TIME))

        if [ $ELAPSED -ge $MAX_DURATION ]; then
            echo "⏸️  Max duration reached (${MAX_DURATION}s). Stopping."
            break
        fi

        echo ""
        echo "🔁 Loop #${LOOP_COUNT} | Elapsed: ${ELAPSED}s"

        STREAM_URL=$(yt-dlp -f "best[height<=720]" -g "$YOUTUBE_URL" 2>/dev/null | tail -1)

        if [ -z "$STREAM_URL" ]; then
            echo "❌ Failed to get stream URL. Retrying in 10s..."
            sleep 10
            continue
        fi

        echo "📡 Streaming..."

        timeout 3600 ffmpeg -loglevel error -re -i "$STREAM_URL" \
            -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,drawtext=text='ZARO LIVE RADIO 24/7':fontcolor=white@0.7:fontsize=24:x=(w-text_w)/2:y=30:box=1:boxcolor=black@0.3:boxborderw=5,fps=60" \
            -c:v libx264 -preset veryfast -b:v 2800k -maxrate 3200k -bufsize 6000k \
            -pix_fmt yuv420p -g 120 -r 60 \
            -c:a aac -b:a 196k -ar 44100 -ac 2 \
            -f flv "$RTMP_URL" 2>&1 | tail -1

        echo "✅ Loop #${LOOP_COUNT} complete"
        sleep 2
    done
else
    STREAM_URL=$(yt-dlp -f "best[height<=720]" -g "$YOUTUBE_URL" 2>/dev/null | tail -1)

    ffmpeg -loglevel info -re -i "$STREAM_URL" \
        -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,drawtext=text='ZARO LIVE RADIO 24/7':fontcolor=white@0.7:fontsize=24:x=(w-text_w)/2:y=30:box=1:boxcolor=black@0.3:boxborderw=5,fps=60" \
        -c:v libx264 -preset veryfast -b:v 2800k -maxrate 3200k -bufsize 6000k \
        -pix_fmt yuv420p -g 120 -r 60 \
        -c:a aac -b:a 196k -ar 44100 -ac 2 \
        -f flv "$RTMP_URL"
fi

echo ""
echo "✅ Stream ended."
