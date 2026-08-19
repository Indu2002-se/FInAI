# Mobile App - Backend Connection Guide

මෙම guide එක mobile app එක backend එක සමග connect කරන්න සඳහා.

## 🔌 Connection Configuration

### File Location
```
lib/app/core/constants/app_constants.dart
```

### Current Configuration
```dart
static const String baseUrl = 'http://localhost:8080/api';
```

## 📱 Device Type අනුව Configuration

### 1. Android Emulator

Android emulator එකෙන් test කරනවා නම්, `localhost` වෙනුවට `10.0.2.2` use කරන්න:

```dart
static const String baseUrl = 'http://10.0.2.2:8080/api';
```

**Why?** Android emulator එකේ `localhost` කියන්නේ emulator එකම refer කරනවා, ඔබේ computer එක නෙමෙයි.

### 2. Physical Device (Same WiFi Network)

Physical device එකකින් (Samsung A075F වගේ) test කරනවා නම්:

**Step 1:** ඔබේ computer IP address එක හොයාගන්න:
```bash
hostname -I | awk '{print $1}'
```

Example output: `192.168.1.100`

**Step 2:** Mobile app එකේ baseUrl update කරන්න:
```dart
static const String baseUrl = 'http://192.168.1.100:8080/api';
```

**Important:**
- ✅ Computer එක සහ phone එක **same WiFi network** එකේ ඉන්න ඕන
- ✅ Backend එක run වෙන්න ඕන (`./gradlew bootRun`)
- ✅ Firewall backend port (8080) block කරලා නැති බව verify කරන්න

### 3. iOS Simulator

iOS simulator එකෙන් (Mac එකක්):
```dart
static const String baseUrl = 'http://localhost:8080/api';
```

iOS simulator එකේ `localhost` work කරයි.

## 🔥 Firewall Configuration (Linux)

Physical device එකකින් connect කරනවා නම්, firewall එකෙන් port 8080 allow කරන්න:

```bash
# Port 8080 allow කරන්න
sudo ufw allow 8080/tcp

# Firewall status check කරන්න
sudo ufw status
```

## 🧪 Connection Test කරන්න

### Backend Health Check

Backend run වෙලා තියනවාද verify කරන්න:

```bash
# Computer එකෙන්
curl http://localhost:8080/api/health

# Phone එකෙන් (browser එකෙන්)
http://192.168.1.100:8080/api/health
```

Expected response:
```json
{
  "success": true,
  "message": "Application is healthy",
  "data": {...}
}
```

### Mobile App Connection Test

App එක run කරලා registration page එකට යන්න. Register කරද්දී:
- ✅ Success: Backend connection හරියට work කරනවා
- ❌ Connection error: Backend URL එක verify කරන්න

## 🔧 Configuration Steps

### Quick Setup (Physical Device)

```bash
# 1. Computer IP එක හොයාගන්න
YOUR_IP=$(hostname -I | awk '{print $1}')
echo "Your IP: $YOUR_IP"

# 2. Backend start කරන්න
cd /media/bbs/30CC197DCC193E92/app/FinAI-Backend
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
./gradlew bootRun

# 3. Mobile app එකේ app_constants.dart update කරන්න
# baseUrl = 'http://$YOUR_IP:8080/api'

# 4. Flutter app rebuild කරන්න
cd /media/bbs/30CC197DCC193E92/app/FInAI/mobile_app
flutter run -d <device-id>
```

## 📝 Configuration Examples

### Development Environments

```dart
class AppConstants {
  // Choose ONE based on your setup:
  
  // Option 1: Local development (emulator)
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  
  // Option 2: Physical device (same network)
  // static const String baseUrl = 'http://192.168.1.100:8080/api';
  
  // Option 3: iOS Simulator
  // static const String baseUrl = 'http://localhost:8080/api';
  
  // Option 4: Remote server (production)
  // static const String baseUrl = 'https://api.finai.com/api';
}
```

### Environment-Based Configuration (Advanced)

```dart
class AppConstants {
  AppConstants._();

  // Use environment variable or flavor-based config
  static String get baseUrl {
    // Check if running on emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    }
    // For iOS or physical device
    return 'http://192.168.1.100:8080/api';
  }
}
```

## 🐛 Common Issues

### Issue 1: Connection Refused
```
Error: Failed to connect to localhost/127.0.0.1:8080
```

**Solutions:**
1. Backend run වෙනවාද check කරන්න
2. Android emulator එකෙන් නම් `10.0.2.2` use කරන්න
3. Physical device එකෙන් නම් computer IP use කරන්න

### Issue 2: Network Error (Physical Device)
```
Error: Network is unreachable
```

**Solutions:**
1. Phone සහ computer same WiFi network එකේද check කරන්න
2. Computer firewall port 8080 allow කරලාද verify කරන්න
3. Backend run වෙනවාද verify කරන්න

### Issue 3: Timeout
```
Error: Connection timeout
```

**Solutions:**
1. Backend logs check කරන්න errors සඳහා
2. Network connection stable ද verify කරන්න
3. `connectTimeout` සහ `receiveTimeout` values increase කරන්න

## 🌐 Network Debugging

### Check Backend Accessibility

Computer එකෙන්:
```bash
# Localhost check
curl http://localhost:8080/api/health

# Network interface check
curl http://192.168.1.100:8080/api/health
```

Phone browser එකෙන්:
```
http://192.168.1.100:8080/api/health
```

### Check Network Connectivity

Phone WiFi settings:
- Same network එකේද verify කරන්න
- IP address range බලන්න (e.g., 192.168.1.x)

Computer network:
```bash
# Network interfaces බලන්න
ip addr show

# WiFi connection
nmcli device show
```

## ✅ Verification Checklist

Backend run කරන කලින්:
- [ ] XAMPP MySQL start කරලාද?
- [ ] Database create කරලාද? (`finai_dev`)
- [ ] Backend dependencies වලින් errors නැද්ද?

Mobile app run කරන කලින්:
- [ ] Backend URL correct ද?
- [ ] Phone සහ computer same network එකේද?
- [ ] Firewall rules configure කරලාද?
- [ ] Flutter clean කරලා rebuild කරලාද?

## 🚀 Complete Test Flow

```bash
# Terminal 1 - Start XAMPP
sudo /opt/lampp/lampp start

# Terminal 2 - Start Backend
cd /media/bbs/30CC197DCC193E92/app/FinAI-Backend
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
./gradlew bootRun

# Terminal 3 - Get your IP and start mobile app
YOUR_IP=$(hostname -I | awk '{print $1}')
echo "Update baseUrl to: http://$YOUR_IP:8080/api"

cd /media/bbs/30CC197DCC193E92/app/FInAI/mobile_app
# Update app_constants.dart with your IP
flutter run -d 192.168.1.5:46507  # Your device ID
```

## 📱 Current Setup

Based on your setup:
- Device: Samsung SM-A075F
- Device ID: `192.168.1.5:46507`
- Computer likely IP: `192.168.1.x` (same network)

Update `baseUrl` in `app_constants.dart`:
```dart
static const String baseUrl = 'http://192.168.1.YOUR_COMPUTER_IP:8080/api';
```

Happy Testing! 🎉
