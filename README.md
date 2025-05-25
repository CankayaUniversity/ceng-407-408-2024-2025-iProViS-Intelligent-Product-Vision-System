# ceng-407-408-2024-2025-iProViS-Intelligent-Product-Vision-System
iProViS: Intelligent Product Vision System
<h1> Project Description </h1>

<p> This project aims to recognize products in retail sectors such as supermarkets, clothing, food, electronics, and others using computer vision technology instead of barcodes or QR codes. The system is designed to develop a mobile application that allows users to access product price information, compare prices across different stores, obtain product content information with multilingual support, and gain detailed insights about products. </p>

<p> Additionally, a new framework has been proposed for recyclable product packaging. The recognized product is integrated into the intelligent recycling process by determining its type through the API of the iPRoVis system and incorporating information such as weight when empty or full. This feature enables users to save time by having their discarded packaging recognized and sorted by smart recycling machines during the recycling process. The developed system not only enhances consumer experience but also contributes significantly to sustainability and environmentally friendly approaches within green IT strategy. </p> </br>

<br>
<table border="1">
    <thead>
        <tr>
            <th>Advisors </th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Assoc. Prof. Dr. Gül TOKDEMİR</td>
        </tr>
        <tr>
            <td>Res. Asst. Sezer UĞUZ</td>
        </tr>
    </tbody>
</table>

<br>
<table border="1">
  <thead>
    <tr>
      <th>Team Member</th>
      <th>Numbers</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Nursena Bitirgen</td>
      <td>202011029</td>
    </tr>
    <tr>
      <td>Tamer Memiş</td>
      <td>201911210</td>
    </tr>
    <tr>
      <td>Furkan Yamaner</td>
      <td>202011211</td>
    </tr>
    <tr>
      <td>Boran Gülbaşar</td>
      <td>202011033</td>
    </tr>
  </tbody>
</table>
<br>

## iProViS User Manual

Welcome to the official user manual for **iProViS (Intelligent Product Vision System)**.  
This mobile application allows users to capture product images, detect the product automatically using ML, and retrieve its pricing and ingredient information from an integrated database.

---

## Table of Contents
1. [Getting Started](#getting-started)
2. [Installation Guide](#installation-guide)
3. [App Features](#app-features)
4. [How to Use](#how-to-use)
   - [Login/Register](#loginregister)
   - [Scan a Product](#scan-a-product)
   - [View Product Details](#view-product-details)
   - [Language Selection](#language-selection)
   - [Theme Settings](#theme-settings)
5. [Security & Privacy](#security--privacy)
6. [Troubleshooting](#troubleshooting)
7. [FAQ](#faq)

---

## Getting Started

**iProViS** is a Flutter-based mobile application. It uses a local machine learning model to detect products and connects to a MongoDB Atlas database for real-time information retrieval.

Supported platforms:
- Android 8.0 and above

---

## Installation Guide

### Option 1: APK Download

1. Visit the [GitHub Releases Page](https://github.com/yourusername/iprovis/releases)
2. Download the latest `iprovis-vx.x.x.apk` file.
3. Transfer it to your Android device if needed.
4. Enable **"Install from Unknown Sources"** in your Android settings.
5. Tap the APK to install.

### Option 2: Build from Source

```bash
flutter pub get
flutter run
```
> Requires Flutter SDK installed.

---

## App Features

- 📷 **Product Scanning**: Capture a photo of a product to identify it using a TFLite AI model.
- 📊 **Product Details**: View price comparisons, nutrition facts, and ingredients.
- 🌍 **Multilingual Interface**: Supports EN, TR, ES, DE, FR.
- 🌓 **Dark/Light Mode**: Switch between themes via settings.
- 🔐 **User Authentication**: Login or register to personalize experience.

---

## How to Use

### Login/Register

1. Launch the app.
2. Tap **"Login"** or **"Register"**.
3. Enter your email and password.
4. Upon successful login, you are redirected to the Home screen.

### Scan a Product

1. On the Home screen, tap the **camera** button.
2. Grant camera permissions.
3. Capture a clear image of the product.
4. The app will detect the product and display the result.

### View Product Details

After detection, you will be navigated to the **Product Info** screen. Tabs include:

- **Prices**: Store-wise price list
- **Nutrition**: Nutritional values
- **Ingredients**: Full list of ingredients

### Language Selection

- Tap the **language icon** in the top-right of the Home screen.
- Select from: English, Turkish, Spanish, German, French
- UI updates automatically.

### Theme Settings

- Navigate to **Profile > Settings**
- Use the toggle to switch between **Dark** and **Light** mode.

---

## Security & Privacy

- All user credentials are stored securely in MongoDB.
- No sensitive data is stored locally.
- Network communication uses SSL by default.

---

## Troubleshooting

| Issue                    | Solution                                |
|-------------------------|-----------------------------------------|
| App crashes on photo    | Check camera permissions                |
| No product found        | Ensure clear image; label should be visible |
| Login fails             | Check credentials or network access     |
| Language doesn't change | Restart app if needed                   |

---

## FAQ

**Q1: Is the app free?**  
Yes, it's fully free.

**Q2: How is product data stored?**  
In MongoDB Atlas, and optionally in a local JSON file.

---

**Thank you for using iProViS!**

