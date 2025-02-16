#!/bin/bash
# gau-js.sh
# 
# このスクリプトはコマンドライン引数からサブドメインを受け取り、
# gau と uro を使用して Wayback Machine などからエンドポイントを収集します。
# その後、js ファイルの URL を抽出してダウンロードします。
#
# This script accepts the subdomain from the command line argument and
# collect endpoints from Wayback Machine etc using gau and uro.
# Then extract the URL of the js file and download it.

#必要に応じてパスを変更してください
#If necessary, please change it to suit your environment.
gau_path="$HOME/bughunt/tools/gau/cmd/gau/gau"


# コマンドライン引数のチェック
# Checking command line arguments
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <subdomain>"
  exit 1
fi

subdomain="$1"
echo "[*] Subdomain: $subdomain"

# 1. gau でエンドポイント収集し、一意にソートして保存
# 1. Collect endpoints with gau, sort and save uniquely
echo "[*] Collecting endpoints using gau..."
"$gau_path" "$subdomain" | sort -u > gau.txt

# 2. uro を使用してフィルタリング（必要に応じてオプションを変更してください）
# 2. Filter using uro (change options as needed)
echo "[*] Filtering endpoints using uro..."
cat gau.txt | uro -o gau-filter.txt

# 3. js ファイルのダウンロード先ディレクトリを作成
# 3. Create a directory to download the js file
mkdir -p js_files

# 4. gau-filter.txt から js ファイル URL を抽出し、curl でダウンロード
# 4. Extract js file URL from gau-filter.txt and download with curl
echo "[*] Downloading JS files..."
while IFS= read -r line; do
  if echo "$line" | grep -q "js$"; then
    echo "Downloading: $line"
    filename=$(echo "$line" | sed 's|https\?://||; s|/|_|g')
    curl -s "$line" -o "js_files/$filename"
  fi
done < gau-filter.txt

echo "[*] Done!"

