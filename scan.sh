#!/bin/bash

# İlk Python dosyasını çalıştır
python3 /home/kali/Desktop/Certificate/not.py

# JSON dosyasını okuyarak fqdn değerlerini al
fqdn_list=$(jq -r '.[].fqdn' fqdn_label.json)

# Çıktı dosyası
output_file="expire.txt"

# Her bir fqdn için sertifika sorgusu yap
for domain in $fqdn_list; do
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

    # Yazılacak çıktı
    output="Domain address: $domain\nNot valid before: $not_valid_before_human\nNot valid after:  $not_valid_after_human\n----------"

    # Çıktıyı dosyaya ekle
    echo -e "$output\n" >> "$output_file"
    
    echo "--------------------------------------"
done

echo "SSL certificate expiration dates have been saved to $output_file"
