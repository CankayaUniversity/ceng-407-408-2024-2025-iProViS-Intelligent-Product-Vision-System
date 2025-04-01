import tensorflow as tf
from tensorflow.keras.preprocessing import image
import numpy as np
import os

# select model
model = tf.keras.models.load_model('../models/iprovis_model_v2.h5')


data_dir = '../dataset'
class_names = sorted(os.listdir(data_dir))

def predict_image(img_path):
    img = image.load_img(img_path, target_size=(224, 224))
    img_array = image.img_to_array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)

    prediction = model.predict(img_array)
    class_index = np.argmax(prediction)
    confidence = np.max(prediction)

    print(f"Predicted Class: {class_names[class_index]}")
    print(f"Confidence Score: {confidence:.2f}")

# image path
test_image_path = '../test_images/testdoritos2.jpg'
predict_image(test_image_path)
