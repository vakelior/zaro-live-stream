# 📵 Zaro Live Stream

24/7 LIVE streaming from YouTube to Restream.io using GitHub Actions.

## 🚀 Quick Setup

1. Add secrets in GitHub (Settings > Secrets > Actions):
   - `YOUTUBE_URL` = `https://youtu.be/UonrUJfMSWk`
   - `RESTREAM_KEY`= `re_12000328_event11d497e43c154270ae00c867bf7d2225`

2. Go to Actions > 1Zaro Live Stream > Run workflow

## 📧 Specs

| Feature | Value |
|---------|------|
| Resolution | 1280x720 (720p) |
| FPS | 60 |
| Video Codec | H264 |
| Audio Codec | AAC |
| Loop | Yes - continuous |
| Run Limit | 6 hours per job |

## 🔜 Auto Restart

The workflow runs automatically every 6 hours via cron.

Reconnects to a new YouTube stream URL every hour to handle expiry tokens.

## 🔵 Custom:

Edit `stream.sh` to change:
- YOUTUBE_URL (default: UonrUJfMSWk)
- RESTREAM_KEY
- MAX_DURATION (default: 21600s)
- LOOP (default: true)

---

📕 GitHub Repo: [vakelior/zaro-live-stream](https://github.com/vakelior/zaro-live-stream)