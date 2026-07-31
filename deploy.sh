#!/bin/bash
# MART Distribution -> GitHub Pages deploy
# Ishlatish:  bash deploy.sh
set -e

USER="otabesirojiddin"
REPO="mart"

cd "$(dirname "$0")"

echo "GitHub Personal Access Token (classic, 'repo' scope) kiriting."
echo "Token ko'rinmaydi (xavfsiz). Yarating:  https://github.com/settings/tokens/new?scopes=repo&description=mart-deploy"
printf "Token: "
read -s TOK
echo
[ -z "$TOK" ] && { echo "Token bo'sh. To'xtatildi."; exit 1; }

API="https://api.github.com"
AUTH="Authorization: token $TOK"

echo "==> Akkaunt tekshirilmoqda..."
WHO=$(curl -s -H "$AUTH" "$API/user" | grep '"login"' | head -1 | cut -d'"' -f4)
[ -z "$WHO" ] && { echo "Token noto'g'ri yoki ruxsat yo'q."; exit 1; }
echo "    Kirildi: $WHO"
USER="$WHO"

echo "==> Repo yaratilmoqda: $USER/$REPO ..."
curl -s -H "$AUTH" "$API/user/repos" \
  -d "{\"name\":\"$REPO\",\"private\":false,\"description\":\"MART Distribution landing\"}" \
  | grep -q '"full_name"' && echo "    Repo tayyor" || echo "    (repo allaqachon bor bo'lishi mumkin, davom etamiz)"

echo "==> Push qilinmoqda..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://$USER:$TOK@github.com/$USER/$REPO.git"
git push -u origin main --force
git remote set-url origin "https://github.com/$USER/$REPO.git"   # tokenni remote'dan tozalash

echo "==> GitHub Pages yoqilmoqda..."
curl -s -X POST -H "$AUTH" -H "Accept: application/vnd.github+json" \
  "$API/repos/$USER/$REPO/pages" \
  -d '{"source":{"branch":"main","path":"/"}}' >/dev/null 2>&1 || true
# agar allaqachon yoqilgan bo'lsa, yangilash:
curl -s -X PUT -H "$AUTH" -H "Accept: application/vnd.github+json" \
  "$API/repos/$USER/$REPO/pages" \
  -d '{"source":{"branch":"main","path":"/"}}' >/dev/null 2>&1 || true

echo
echo "================================================================"
echo "  ✅ TAYYOR!"
echo "  Link:  https://$USER.github.io/$REPO/"
echo "  (1-2 daqiqada faollashadi)"
echo "================================================================"
echo
echo "Xavfsizlik: kerak bo'lmasa tokenni o'chiring -> https://github.com/settings/tokens"
