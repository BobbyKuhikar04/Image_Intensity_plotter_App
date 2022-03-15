from flask import Flask, jsonify, request
import cv2
import numpy as np
import matplotlib.pyplot as plt
import werkzeug
import io
from PIL import Image
import urllib
import base64
import os
import sys


app = Flask(__name__)


@app.route('/upload', methods=['POST'])
def upload():
    imagefile = request.files['image']
    imagefile.save('./Inputimages/'+"something.jpg")
    path = r'./Inputimages/something.jpg'
   # path2 = r'./Inputimages/something1.jpg'
    src = cv2.imread(path)
    gray(src)
    rgb(src)
    print("success")

    return jsonify({
        "processed": "it is uploaded successfully we can continue"
    })


def gray(src):
    imagey = cv2.cvtColor(src, cv2.COLOR_BGR2GRAY)

    plt.hist(x=imagey.ravel(), bins=256, range=[0, 256], color='navy')
    plt.ylabel("Pixels Distribution", color="darkolivegreen")
    plt.xlabel("Pixel Intensity", color="crimson")

    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    buf.seek(0)

    imy = Image.open(buf)

    imy.save('../camera/assests/'+"gray3.png")
    plt.close()


def rgb(src2):
    (B, G, R) = cv2.split(src2)
    plt.hist(x=G.ravel(), bins=256, range=[
             0, 256], color='green', histtype='step')
    plt.hist(x=R.ravel(), bins=256, range=[
             0, 256], color='crimson', histtype='step')
    plt.hist(x=B.ravel(), bins=256, range=[
             0, 256], color='blue', histtype='step')
    plt.title("RGB Distribution")
    plt.ylabel("Pixels Distribution", color="darkolivegreen")
    plt.xlabel("Pixel Intensity", color="crimson")

    b = io.BytesIO()
    plt.savefig(b, format='png')
    b.seek(0)

    rgbimage = Image.open(b)

    rgbimage.save('../camera/assests/'+"rgb3.png")
    plt.close()


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=8000)
