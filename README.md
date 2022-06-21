# Azkagram

Telegram Open source based flutter and dart, dengan tampilan terbaru + tambahan feature integrated apps dari [HEXAMINATE](https://hexaminate.netlify.app/)

Kasih saya stars agar saya mempercepat update azkagram

## Feature now
- ✅️ support login bot and userbot

## Feature next
if you stars  my repo i will publish feature to azkagram
- 100 stars
  - i will add feature text to speech
  - i will add feature brainly
  - i will add feature wiki
- 1k stars
  -  i will add code load config.json for automation your account
  -  i will add story update for contact
- 10k
  - i will add editor script code in app for edit automation account

## Screenshot​
 
<img src="https://user-images.githubusercontent.com/82513502/173433798-9e29f5e3-ee0f-425f-a24b-2134de3d3cf9.png" width="250px"><img src="https://raw.githubusercontent.com/azkadev/azkagram/main/screenshot/me.png" width="250px">

<img src="https://user-images.githubusercontent.com/82513502/173319331-9e96fbe7-3e66-44b2-8577-f6685d86a368.png" width="250px"><img src="https://user-images.githubusercontent.com/82513502/173319541-19a60407-f410-4e95-8ac0-d0da2eaf2457.png" width="250px">

 
![Screenshot from 2022-06-09 22-03-39](https://user-images.githubusercontent.com/82513502/172880974-7bd13318-7934-4bca-acfb-911da5982ba5.png)
![Screenshot from 2022-06-09 22-06-07](https://user-images.githubusercontent.com/82513502/172880794-3eae08b8-3e55-40ed-8300-9427dd291118.png)

## build
Clone dulu reponya ya deck:V
```bash
git clone https://github.com/azkadev/azkagram.git
cd azkagram
flutter pub get
```


1. Android

```bash
flutter build apk --release
```

2. Linux 

```bash
flutter build linux --release
```

3. Windows

```bash
flutter build windows --release
```

4. macOS

```bash
flutter build macos --release
```

5. Github action

clone repo saya abis itu tap action lalu jalankan workflows ini

![Screenshot from 2022-06-22 02-24-08](https://user-images.githubusercontent.com/82513502/174882193-0bca3742-dae4-4b09-b06b-f62b6c5b5af5.png)


## Development

1. Clone Project

```bash
git clone https://github.com/azkadev/azkagram.git
cd azkagram
```

2. download package

```dart
flutter pub get
```

3. Run

```dart
flutter run
```

Jika terjadi error path tdlib tidak ada maka kalian harus compile sendiri ya [Compile Tdlib](https://github.com/tdlib/td)


Jika sudah kalian copy hasil compile tdlib

1. Android
  `android/app/src/jniLibs/{arch_android}/libtdjson.so`
  example:
  `azkagram/android/app/src/jniLibs/arm64-v8a/libtdjson.so`
  
  + build.gradle
  contoh kalian bisa liat di `android/app/build.gradle`
  ```bash
  main {
    jniLibs.srcDirs = ['src/jniLibs']
  }
  ```

2. Linux
   - Method 1
    paste hasil libtdjson.so ke path `/usr/lib/libtdjson.so`
     
3. Windows
   saya tidak tahu karena saya tidak pakai windows

4. macOS
   Saya tidak tahu karena saya tidak pakai macOS

5. iOS
   saya tidak tahu karena saya tidak pakai iOS

