import os
import cv2

# Dataset klasör yolu
dataset_path = 'dataset'

# İstenilen resim boyutu
img_height, img_width = 224, 224

# Tüm klasörleri dolaş
for root, dirs, files in os.walk(dataset_path):
    for filename in files:
        if filename.lower().endswith(('.jpg', '.jpeg')):
            file_path = os.path.join(root, filename)
            
            # Resmi yükle
            img = cv2.imread(file_path)

            # Resmi yeniden boyutlandır (resize)
            resized_img = cv2.resize(img, (img_width, img_height))

            # Resmin üzerine yaz
            cv2.imwrite(file_path, resized_img)
            print(f'{file_path} resized to {img_width}x{img_height}')

print("Tüm resimler başarıyla yeniden boyutlandırıldı.")
