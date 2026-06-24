#!/bin/bash
# One-shot: create GitHub repo + push + give Render deploy URL
# Run this from C:\Users\ruizi\polymarket-hub\proxy

echo "=== CLOB PROXY DEPLOY ==="
echo ""

# Get token from user (won't be saved)
read -sp "GitHub Personal Access Token: " GH_TOKEN
echo ""

# Create repo
echo "Creating GitHub repo..."
RESP=$(curl -s -H "Authorization: token $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/user/repos" \
  -d '{"name":"clob-proxy","private":false,"auto_init":false}')

REPO_URL=$(echo "$RESP" | python -c "import json,sys; print(json.load(sys.stdin).get('clone_url',''))" 2>/dev/null)

if [ -z "$REPO_URL" ]; then
    echo "Failed to create repo:"
    echo "$RESP"
    exit 1
fi

echo "Repo: $REPO_URL"

# Push
git remote add origin "$REPO_URL" 2>/dev/null
# Use token in URL for push
PUSH_URL=$(echo "$REPO_URL" | sed "s|https://|https://$GH_TOKEN@|")
git push "$PUSH_URL" master 2>&1

echo ""
echo "============================================"
echo " REPO PUSHED"
echo "============================================"
echo ""
echo "Now go to: https://render.com"
echo "1. Sign up with GitHub"
echo "2. Click 'New' → 'Web Service'"
echo "3. Paste this URL: $REPO_URL"
echo "4. Click 'Connect' → 'Deploy'"
echo ""
echo "Render gives you a URL like: https://clob-proxy.onrender.com"
echo "Give me that URL and I'll wire up your trader."
