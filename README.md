## 🛒 Shopping – Mobile App (Flutter)

A full mobile application for managing a products store.

The app uses a local SQLite database with automatic online synchronization to Firebase Firestore, and product image uploads through Cloudinary.

It supports both online and offline modes to ensure your data is always safe and available even without an internet connection.

## 🚀 Features

- Add, edit, and delete products.

- Store product data locally using SQLite.

- Auto-sync data with Firebase Firestore whenever internet becomes available.

- Upload product images to Cloudinary.

- Offline mode with pending sync queue.

- Check network status using connectivity_plus.

- Clean project architecture: MVC + Controller Pattern.

- Simple, fast, and responsive UI for product management.

## 📱 Technologies Used
### 🔹 Flutter

Used to build the entire UI and app logic with smooth Material Design components.

## 🔹 SQLite – Local Database

### The local database is responsible for:

- Storing all product data offline.

- Ensuring the app works even without internet.

- Keeping unsynced data until the device reconnects.


## 🧩 How SQLite & Firebase Work Together (Sync System)

The app uses a hybrid Offline-First architecture:

### ✔ When Internet is available:

- User adds a product.

- Image is uploaded to Cloudinary.

- Product data is saved into Firebase Firestore.

- The same data is stored into SQLite with syncStatus = 0.

✔ When Internet is NOT available:

Product is stored locally only in SQLite with syncStatus = 1.

No image upload is done.

### When internet returns:

- App detects connectivity.

- It uploads the pending data to Firebase.

- Updates syncStatus to 0.

- This ensures zero data loss and a smooth offline-first experience.

### 🔹 Firebase Firestore

- Used as the cloud backend:

- Saves all product documents.

- Provides real-time access when online.

- Used for syncing local data with the cloud.

### 🔹 Cloudinary

Used to handle image uploading, returning a secure image URL stored in both SQLite and Firebase.

### Benefits:

- Fast global CDN.

- Unlimited transformations.

- Very stable free tier for development.
 
 
