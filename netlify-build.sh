#!/usr/bin/env bash
set -euo pipefail

# 出力先を用意（CNAMEは除外。GitHub Pages用なのでプレビューには不要）
rm -rf out
rsync -av --delete --exclude ".git" --exclude "out" --exclude "CNAME" ./ out/
cd out

# 1) 「? を含むファイル」を ? 以降を除いた名前で複製
#    例: style.css?ver=1.0 → style.css
find . -type f -name "*\?*" | while read -r f; do
  base="${f%%\?*}"
  mkdir -p "$(dirname "$base")"
  cp -f "$f" "$base"
done

# 2) HTML/CSS/JS 内の参照からクエリ(?ver=..., &fver=...)を除去
find . -type f \( -name "*.html" -o -name "*.css" -o -name "*.js" \) -print0 \
  | xargs -0 sed -i -E 's/\?ver=[^"'\'' )]+//g; s/&fver=[^"'\'' )]+//g'

# 3) 念のため Jekyll を無効化
touch .nojekyll

echo "Prepared cleaned site in ./out"
