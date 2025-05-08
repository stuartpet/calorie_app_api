# 🧠 HealthKit & Google Fit Integration Plan

This document outlines how we'll integrate Apple Health (HealthKit) and Google Fit into the CalorieApp so we can sync calories burned from workouts and movement into the user's daily totals.

---

## ✅ Goals

- Read **Active Energy Burned (calories)** from Apple HealthKit on iOS
- Read **Calories Expended** from Google Fit on Android
- Add calories burned to user’s daily calorie balance
- Make this feature optional and toggleable in Settings

---

## 📱 Apple Health (HealthKit) – iOS Only

### 1. Install Native Module
```bash
npm install react-native-health
```

### 2. Enable HealthKit in Xcode
- Open `ios/CalorieApp.xcworkspace`
- Go to `Signing & Capabilities`
- Add `HealthKit`

### 3. Add Permissions to `Info.plist`
```xml
<key>NSHealthShareUsageDescription</key>
<string>We use HealthKit to sync calories burned.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>We use HealthKit to log calories burned from workouts.</string>
```

### 4. Sample Usage
```js
import AppleHealthKit from 'react-native-health';

const options = {
  permissions: {
    read: ['ActiveEnergyBurned'],
  },
};

AppleHealthKit.initHealthKit(options, (err) => {
  if (err) return;

  AppleHealthKit.getActiveEnergyBurned(
    { startDate: new Date().toISOString() },
    (err, results) => {
      if (!err) console.log('🍎 Calories burned:', results);
    }
  );
});
```

---

## 🤖 Google Fit – Android Only

### 1. Install Native Module
```bash
npm install react-native-google-fit
```

### 2. Enable Google Fit API
- Go to [Google Cloud Console](https://console.cloud.google.com/)
- Enable **Fitness API**
- Create OAuth credentials

### 3. Add Permission to `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
```

### 4. Sample Usage
```js
import GoogleFit from 'react-native-google-fit';

GoogleFit.authorize().then(authResult => {
  if (authResult.success) {
    const options = {
      startDate: new Date(new Date().setHours(0,0,0,0)).toISOString(),
      endDate: new Date().toISOString(),
    };

    GoogleFit.getDailyCalorieSamples(options, (err, res) => {
      if (!err) console.log('🔥 Google Fit calories:', res);
    });
  }
});
```

---

## 🔐 Privacy Considerations

- Always ask for permission explicitly
- Allow users to toggle HealthKit/Fit integration in settings
- Do not sync health data to external servers without consent

---

## 🚀 Roadmap

| Task | Status |
|------|--------|
| Add HealthKit support | ⬜️ Not started |
| Add Google Fit support | ⬜️ Not started |
| Toggle integration in settings | ⬜️ Not started |
| Adjust calorie total in dashboard | ⬜️ Not started |
| Show sync status in UI | ⬜️ Not started |

---

## 💡 Next Steps

- [ ] Branch: `feature/health-integration`
- [ ] Begin with iOS (HealthKit) for MVP
- [ ] Add analytics logging for sync