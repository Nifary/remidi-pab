# SpaceNews Core 🚀
Advanced International News Portal — Flutter App

## Fitur
- Splash Screen (3 detik + session check)
- Register / Login / Forgot Password via Firebase Auth
- Welcome Page
- Home Feed dari SpaceflightNews API
- Detail Article + Tambah ke Favorit (Firestore)
- Halaman Favorit (real-time Firestore stream)
- Halaman Notifikasi
- Halaman Profile (data dari Firestore, Logout)

---

## Setup Wajib Sebelum Run

### 1. Buat Firebase Project
1. Buka https://console.firebase.google.com
2. Buat project baru (nama bebas)
3. Aktifkan **Authentication → Email/Password**
4. Aktifkan **Firestore Database** (mode production atau test)

### 2. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 3. Configure Firebase ke project ini
```bash
cd spacenews_core
flutterfire configure
```
> File `lib/firebase_options.dart` akan terbuat otomatis. **Hapus file placeholder lama.**

### 4. Tambahkan google-services.json (Android)
- Di Firebase Console → Project Settings → Android → Download `google-services.json`
- Taruh di `android/app/google-services.json`

Pastikan `android/app/build.gradle` memiliki:
```gradle
apply plugin: 'com.google.gms.google-services'
```

Dan `android/build.gradle` memiliki:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

### 5. Install dependencies & run
```bash
flutter pub get
flutter run
```

---

## Struktur Firestore

### Collection: `users/{uid}`
```json
{
  "name": "Nama Pengguna",
  "email": "user@email.com",
  "instagram": "handle_instagram",
  "photoUrl": "https://...",
  "createdAt": "<timestamp>"
}
```

### Collection: `favorites/{uid}_{articleId}`
```json
{
  "id": 12345,
  "title": "Judul Artikel",
  "uid": "firebase_uid"
}
```

---

## API
- **Base URL**: `https://api.spaceflightnewsapi.net/v4/articles/?limit=20`
- Tidak perlu API key
- Response: `{ results: [...] }`

---

## Pengumpulan
1. Upload source code ke GitHub (pastikan `.gitignore` mengecualikan `google-services.json`)
2. Kirim link repo ke GForm yang ada di grup Telegram
