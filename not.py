import requests
import os
import json

url = "https://api.arns.app/v1/contract/bLAgYxAdX2Ry-nt6aH2ixgvJXbpsEYm28NgJgyqfs-U/read/gateways"
headers = {"Host": "api.arns.app"}

# GET isteği gönderip Gateways.txt dosyasına yazma
response = requests.get(url, headers=headers)

if response.status_code == 200:
    desktop_path = "/home/kali/Desktop/Certificate"
    if not os.path.exists(desktop_path):
        os.makedirs(desktop_path)

    # Gateways.txt dosyasını oluştur ve verileri yaz
    with open(os.path.join(desktop_path, "Gateways.txt"), "w") as file:
        file.write(response.text)
        #print("Veriler başarıyla Gateways.txt dosyasına kaydedildi.")
        
    # Gateways.txt dosyasından fqdn ve label değerlerini alıp JSON formatında yazma
    data = response.text
    start_index_fqdn = data.find('"fqdn":')  # İlk "fqdn": dizinini bul
    start_index_label = data.find('"label":')  # İlk "label": dizinini bul
    fqdn_values = []
    label_values = []

    while start_index_fqdn != -1 and start_index_label != -1:
        end_index_fqdn = data.find('"', start_index_fqdn + 8)  # start_index_fqdn + 8'den sonraki " işaretini bul
        fqdn = data[start_index_fqdn + 8:end_index_fqdn]  # "fqdn":'den sonraki değeri al
        fqdn_values.append(fqdn)

        end_index_label = data.find('"', start_index_label + 9)  # start_index_label + 9'den sonraki " işaretini bul
        label = data[start_index_label + 9:end_index_label]  # "label":'den sonraki değeri al
        label_values.append(label)

        start_index_fqdn = data.find('"fqdn":', end_index_fqdn)  # Bir sonraki "fqdn": dizinini bul
        start_index_label = data.find('"label":', end_index_label)  # Bir sonraki "label": dizinini bul

    # fqdn ve label değerlerini JSON formatında kaydet
    fqdn_label_info = [{"fqdn": fqdn, "label": label} for fqdn, label in zip(fqdn_values, label_values)]
    with open(os.path.join(desktop_path, "fqdn_label.json"), "w") as fqdn_label_file:
        json.dump(fqdn_label_info, fqdn_label_file, indent=4)

    #print("fqdn ve label değerleri başarıyla fqdn_label.json dosyasına kaydedildi.")
    
    # Gateways.txt dosyasını sil
    os.remove(os.path.join(desktop_path, "Gateways.txt"))
    #print("Gateways.txt dosyası silindi.")
#else:
    #print("Hata: İstek başarısız oldu. HTTP kodu:", response.status_code)
