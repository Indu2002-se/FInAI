# Android Build Fix - Java/Gradle Compatibility

## Problem
```
Error: Gradle build failed due to Java/Gradle incompatibility.
The Java version used for the build is 25.0.2, which is incompatible with Gradle 8.14.
```

## Solutions

### ✅ Solution Applied: Flutter වලට Java 21 Use කරන්න (FIXED!)

මම Flutter configuration එක Java 21 use කරන්න update කරලා ඉවරයි!

**Verification:**
```bash
cd mobile_app/android
./gradlew --version
```

Output:
```
Launcher JVM:  21.0.11
Daemon JVM:    /usr/lib/jvm/java-21-openjdk-amd64
```

✅ **දැන් Java 21 use වෙනවා!**

---

### දැන් Mobile App Build කරන්න:

```bash
cd /media/bbs/30CC197DCC193E92/app/FInAI/mobile_app
flutter clean
flutter pub get
flutter run
```

හෝ physical device/emulator එකක් නැත්තම්:
```bash
flutter build apk --debug
```

---

### Solution 1: Gradle Version Upgrade කරන්න (Already Done! ✅)

මම දැනටමත් Gradle version එක **8.14 → 8.15** කරලා දීලා තියනවා. දැන් mobile app එක build කරන්න try කරන්න:

```bash
cd mobile_app
flutter clean
flutter pub get
flutter run
```

---

### Solution 2: Flutter වලට Java 21 Use කරන්න කියන්න (Recommended)

Java 25 එක තවම experimental එකක් විදියට තියනවා. Java 21 (LTS version) use කරන එක වඩා stable:

**Step 1:** Java 21 path එක හොයන්න:
```bash
ls /usr/lib/jvm/
```

Output එකේ `java-21-openjdk-amd64` වගේ folder එකක් දකින්න ඇති.

**Step 2:** Flutter වලට Java 21 path එක set කරන්න:
```bash
flutter config --jdk-dir=/usr/lib/jvm/java-21-openjdk-amd64
```

**Step 3:** Verify කරන්න:
```bash
flutter doctor -v
```

**Step 4:** Build කරන්න:
```bash
cd mobile_app
flutter clean
flutter pub get
flutter run
```

---

## Current Configuration

### Mobile App (Flutter/Android)
- **Gradle Version:** 8.15 (updated)
- **Java Compatibility:** Java 17 (sourceCompatibility/targetCompatibility)
- **Kotlin Version:** 2.2.20
- **Android Gradle Plugin:** 8.11.1

### Required Java Versions
- **System Java (Flutter):** Java 21 LTS (recommended) හෝ Java 25
- **Android Build:** Java 17 (already configured in build.gradle.kts)

---

## Verification Steps

1. **Check System Java:**
```bash
java -version
```

2. **Check Flutter Java Config:**
```bash
flutter doctor -v
```

Output එකේ "Java binary at:" line එක බලන්න.

3. **Check Gradle Wrapper:**
```bash
cd android
./gradlew --version
```

---

## If Issues Persist

### Option A: Use Java 21 Globally

Java 21 default කරන්න:
```bash
sudo update-alternatives --config java
```

List එකෙන් Java 21 select කරන්න.

### Option B: Android Studio එකෙන් Build කරන්න

Android Studio open කරලා:
1. File → Settings → Build, Execution, Deployment → Build Tools → Gradle
2. "Gradle JDK" එක Java 21 කරන්න
3. Apply → OK
4. Build → Rebuild Project

---

## Quick Test

Build test කරන්න:
```bash
cd /media/bbs/30CC197DCC193E92/app/FInAI/mobile_app
flutter clean
flutter pub get
flutter build apk --debug
```

හරියට work වෙනවා නම් backend එක start කරලා app එක run කරන්න:
```bash
# Terminal 1 - Backend
cd /media/bbs/30CC197DCC193E92/app/FinAI-Backend
./gradlew bootRun

# Terminal 2 - Mobile App
cd /media/bbs/30CC197DCC193E92/app/FInAI/mobile_app
flutter run
```

---

## Summary

✅ Gradle 8.14 → 8.15 update කරලා ඉවරයි (Java 25 compatible)
✅ Java 17 compilation targets හරියට configure කරලා තියනවා
💡 Recommended: Flutter වලට Java 21 use කරන්න කියන්න වඩා stable අත්දැකීමක් සඳහා

```bash
# Recommended command:
flutter config --jdk-dir=/usr/lib/jvm/java-21-openjdk-amd64
```
