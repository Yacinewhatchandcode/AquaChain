#!/bin/bash
set -e

# Rename files in mockups to simpler names
mv mockups/aquachain_dashboard_mockup_*.png mockups/dashboard.png || true
mv mockups/aquachain_mobile_rights_card_*.png mockups/mobile_rights.png || true
mv mockups/aquachain_alert_proof_screen_*.png mockups/alert_proof.png || true

# Generate audio
echo "Generating audio..."
say -v "Paulina" -f pitch_tts.txt -o pitch_audio.aiff

# Get audio length
DURATION=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 pitch_audio.aiff)
IMG_DURATION=$(echo "$DURATION / 3" | bc -l)

echo "Audio duration: $DURATION sec"
echo "Image duration: $IMG_DURATION sec"

# Create a text file with image duration sequence
cat <<EOF > images.txt
file 'mockups/dashboard.png'
duration $IMG_DURATION
file 'mockups/mobile_rights.png'
duration $IMG_DURATION
file 'mockups/alert_proof.png'
duration $IMG_DURATION
file 'mockups/alert_proof.png'
EOF

# Build final video
echo "Building video..."
/opt/homebrew/bin/ffmpeg -y -f concat -safe 0 -i images.txt -i pitch_audio.aiff -c:v libx264 -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -c:a aac -b:a 192k -shortest AquaChain_DoraHacks_Pitch.mp4

echo "Video building complete!"
