# convert_h5_to_tflite.py
import tensorflow as tf
from tensorflow.keras.models import load_model

def convert_h5_to_tflite(h5_model_path, tflite_model_path, quantize=False):
    """
    Keras .h5 modelini TensorFlow Lite'a dönüştürür
    
    Parametreler:
        h5_model_path: .h5 model dosyasının yolu (örn: 'model.h5')
        tflite_model_path: Kaydedilecek .tflite dosyasının yolu (örn: 'model.tflite')
        quantize: Modeli quantize etmek için (boyutu küçültür, hızlandırır)
    """
    try:
        # Modeli yükle
        print(f"{h5_model_path} modeli yükleniyor...")
        model = load_model(h5_model_path)
        
        # Converter oluştur
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        
        # Quantization ayarları (isteğe bağlı)
        if quantize:
            print("Quantization uygulanıyor...")
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            converter.target_spec.supported_types = [tf.float16]  # veya tf.int8
        
        # Dönüştürme işlemi
        print("TFLite modeline dönüştürülüyor...")
        tflite_model = converter.convert()
        
        # Dosyaya kaydet
        with open(tflite_model_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"✅ Model başarıyla kaydedildi: {tflite_model_path}")
        print(f"Boyut: {len(tflite_model) / 1024:.2f} KB")
        
    except Exception as e:
        print(f"❌ Hata oluştu: {str(e)}")

if __name__ == "__main__":
    # Örnek kullanım
    convert_h5_to_tflite(
    h5_model_path="../models/iprovis_model_v2.h5",
    tflite_model_path="../models/iprovis_model.tflite",
    quantize=True
)