#!/bin/bash

# İlk Python dosyasını çalıştır
python3 /home/kali/Desktop/Certificate/not.py

# JSON dosyasını okuyarak fqdn ve label değerlerini al
jq -r '.[] | "\(.fqdn) \(.label)"' fqdn_label.json | while read -r domain label; do
    # Eğer satır boşsa veya başka bir nedenle geçersizse atla
    if [[ -z "$domain" ]]; then
        continue
    fi

    echo "Checking SSL certificate for $domain..."

    # Run Nmap and filter output for SSL certificate validity dates
    nmap_output=$(nmap -p 443 --script ssl-cert --script-args 'ssl-cert.intense' -n $domain | grep -E "Not valid (before|after)" | sed 's/|//g')

    # Formatı düzenle
    not_valid_before=$(echo "$nmap_output" | grep "Not valid before" | sed 's/Not valid before: //')
    not_valid_after=$(echo "$nmap_output" | grep "Not valid after" | sed 's/Not valid after:  //')

    # İnsan dostu zaman formatına dönüştür
    not_valid_before_human=$(date -d "$not_valid_before" +"%Y-%m-%d %H:%M:%S")
    not_valid_after_human=$(date -d "$not_valid_after" +"%Y-%m-%d %H:%M:%S")

    # JSON formatında çıktı oluştur
    output="{\"domain\": \"$domain\", \"label\": \"$label\", \"not_valid_before\": \"$not_valid_before_human\", \"not_valid_after\": \"$not_valid_after_human\"}"

    # Çıktıyı dosyaya ekle
    echo "$output" >> "expire.json"
done

echo "SSL certificate expiration dates have been saved to expire.json"
