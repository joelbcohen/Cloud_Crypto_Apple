# Xcode Project File Checklist

This document lists all the files that should be included in your Xcode project. Use this checklist to ensure all files are properly added to the Watch App target.

## ✅ How to Add Files to Xcode

1. Right-click on the group folder in Xcode
2. Select "Add Files to [Project Name]..."
3. Select the files
4. Ensure "Watch App" target is checked
5. Click "Add"

OR

1. Drag files from Finder into Xcode
2. In the dialog, ensure:
   - ☑️ "Copy items if needed"
   - ☑️ "Create groups"
   - ☑️ Watch App target is selected
3. Click "Finish"

## 📁 File Checklist by Category

### App Entry Points (2 files)

```
☐ Cloud_CryptoApp.swift          # Main app entry point
☐ ContentView.swift              # Root view
```

**Target**: Watch App
**Group**: Root or App group

### ViewModels (1 file)

```
☐ ViewModels/RegistrationViewModel.swift
```

**Target**: Watch App
**Group**: ViewModels

### Views (6 files)

```
☐ Views/MainScreenView.swift
☐ Views/RegistrationFormView.swift
☐ Views/AccountSummaryView.swift
☐ Views/TransferView.swift
☐ Views/LoadingView.swift
☐ Views/ErrorView.swift
```

**Target**: Watch App
**Group**: Views

### Models (3 files)

```
☐ Models/RegistrationModels.swift
☐ Models/AccountModels.swift
☐ Models/RegistrationStatus.swift
```

**Target**: Watch App
**Group**: Models

### Services (5 files)

```
☐ Services/NetworkService.swift
☐ Services/DeviceInfoService.swift
☐ Services/KeychainService.swift
☐ Services/AttestationService.swift
☐ Services/APNsService.swift
```

**Target**: Watch App
**Group**: Services

### Repositories (1 file)

```
☐ Repositories/RegistrationRepository.swift
```

**Target**: Watch App
**Group**: Repositories

### Utilities (2 files)

```
☐ Utilities/UserDefaultsManager.swift
☐ Utilities/NumberFormatter+Extensions.swift
```

**Target**: Watch App
**Group**: Utilities

### Complications (1 file)

```
☐ Complications/CloudCryptoComplication.swift
```

**Target**: Widget Extension (if separate) or Watch App
**Group**: Complications

**Note**: If you want complications as a separate target, you'll need to create a Widget Extension target first.

### Documentation (5 files - Optional)

```
☐ README.md
☐ PROJECT-SUMMARY.md
☐ Documentation/Architecture-Overview.md
☐ Documentation/Setup-And-Deployment.md
☐ Documentation/InfoPlist-Configuration.md
☐ Documentation/Quick-Start-Guide.md
```

**Target**: None (documentation only)
**Group**: Documentation or root

## 📊 Summary

| Category | File Count | Group Name |
|----------|------------|------------|
| App Entry | 2 | Root |
| ViewModels | 1 | ViewModels |
| Views | 6 | Views |
| Models | 3 | Models |
| Services | 5 | Services |
| Repositories | 1 | Repositories |
| Utilities | 2 | Utilities |
| Complications | 1 | Complications |
| **Total Swift Files** | **21** | |
| Documentation | 6 | Documentation |

## 🎯 Recommended Xcode Project Structure

```
Cloud Crypto Watch App
│
├── 📁 App
│   ├── Cloud_CryptoApp.swift
│   └── ContentView.swift
│
├── 📁 ViewModels
│   └── RegistrationViewModel.swift
│
├── 📁 Views
│   ├── MainScreenView.swift
│   ├── RegistrationFormView.swift
│   ├── AccountSummaryView.swift
│   ├── TransferView.swift
│   ├── LoadingView.swift
│   └── ErrorView.swift
│
├── 📁 Models
│   ├── RegistrationModels.swift
│   ├── AccountModels.swift
│   └── RegistrationStatus.swift
│
├── 📁 Services
│   ├── NetworkService.swift
│   ├── DeviceInfoService.swift
│   ├── KeychainService.swift
│   ├── AttestationService.swift
│   └── APNsService.swift
│
├── 📁 Repositories
│   └── RegistrationRepository.swift
│
├── 📁 Utilities
│   ├── UserDefaultsManager.swift
│   └── NumberFormatter+Extensions.swift
│
├── 📁 Complications
│   └── CloudCryptoComplication.swift
│
├── 📁 Resources
│   ├── Assets.xcassets
│   ├── Preview Content
│   └── Info.plist
│
└── 📁 Documentation
    ├── README.md
    ├── PROJECT-SUMMARY.md
    ├── Architecture-Overview.md
    ├── Setup-And-Deployment.md
    ├── InfoPlist-Configuration.md
    └── Quick-Start-Guide.md
```

## 🔍 Verification Steps

### Step 1: Check File Membership

For each Swift file:
1. Select the file in Xcode
2. Open File Inspector (⌥⌘1)
3. Under "Target Membership", ensure:
   - ☑️ Watch App is checked
   - ☐ Watch App Extension is unchecked (unless needed)

### Step 2: Build the Project

```
1. Select Watch App scheme
2. Choose a destination (simulator or device)
3. Press ⌘B to build
4. Fix any missing file errors
```

### Step 3: Verify Groups

Ensure all files are in their correct groups:
- Use the folder structure shown above
- This makes the project easier to navigate
- Matches the recommended architecture

### Step 4: Check Info.plist

Ensure Info.plist includes:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>

<key>NSUserNotificationsUsageDescription</key>
<string>Cloud Crypto needs notification access to receive updates about your account and transactions.</string>
```

## ⚠️ Common Issues

### Issue: "Cannot find type 'RegistrationViewModel' in scope"

**Solution**: 
- Ensure `RegistrationViewModel.swift` is in Watch App target
- Check target membership in File Inspector
- Clean and rebuild (⌘⇧K)

### Issue: "No such module 'WatchKit'"

**Solution**:
- Ensure you're building for watchOS
- Check deployment target is watchOS 9.0+
- Verify Watch App target settings

### Issue: Build succeeds but files not found at runtime

**Solution**:
- Verify target membership for all files
- Clean derived data: Xcode > Preferences > Locations > Derived Data > Delete
- Rebuild project

### Issue: Complications not appearing

**Solution**:
- If complications are in a separate target:
  - Create Widget Extension target
  - Add CloudCryptoComplication.swift to that target
- If in main app:
  - Ensure WidgetKit is imported
  - Verify @main attribute on widget

## 🚀 Quick Setup Script

You can verify all files exist with this terminal command:

```bash
# Run from project root directory
echo "Checking Swift files..."

files=(
    "Cloud_CryptoApp.swift"
    "ContentView.swift"
    "ViewModels/RegistrationViewModel.swift"
    "Views/MainScreenView.swift"
    "Views/RegistrationFormView.swift"
    "Views/AccountSummaryView.swift"
    "Views/TransferView.swift"
    "Views/LoadingView.swift"
    "Views/ErrorView.swift"
    "Models/RegistrationModels.swift"
    "Models/AccountModels.swift"
    "Models/RegistrationStatus.swift"
    "Services/NetworkService.swift"
    "Services/DeviceInfoService.swift"
    "Services/KeychainService.swift"
    "Services/AttestationService.swift"
    "Services/APNsService.swift"
    "Repositories/RegistrationRepository.swift"
    "Utilities/UserDefaultsManager.swift"
    "Utilities/NumberFormatter+Extensions.swift"
    "Complications/CloudCryptoComplication.swift"
)

missing=0
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file MISSING"
        ((missing++))
    fi
done

if [ $missing -eq 0 ]; then
    echo ""
    echo "🎉 All files present!"
else
    echo ""
    echo "⚠️  $missing file(s) missing"
fi
```

Save as `verify-files.sh`, make executable with `chmod +x verify-files.sh`, and run with `./verify-files.sh`

## 📝 Manual Verification Checklist

Go through each file and check it off:

### App Entry (2)
- [ ] Cloud_CryptoApp.swift exists and is in target
- [ ] ContentView.swift exists and is in target

### ViewModels (1)
- [ ] RegistrationViewModel.swift exists and is in target

### Views (6)
- [ ] MainScreenView.swift exists and is in target
- [ ] RegistrationFormView.swift exists and is in target
- [ ] AccountSummaryView.swift exists and is in target
- [ ] TransferView.swift exists and is in target
- [ ] LoadingView.swift exists and is in target
- [ ] ErrorView.swift exists and is in target

### Models (3)
- [ ] RegistrationModels.swift exists and is in target
- [ ] AccountModels.swift exists and is in target
- [ ] RegistrationStatus.swift exists and is in target

### Services (5)
- [ ] NetworkService.swift exists and is in target
- [ ] DeviceInfoService.swift exists and is in target
- [ ] KeychainService.swift exists and is in target
- [ ] AttestationService.swift exists and is in target
- [ ] APNsService.swift exists and is in target

### Repositories (1)
- [ ] RegistrationRepository.swift exists and is in target

### Utilities (2)
- [ ] UserDefaultsManager.swift exists and is in target
- [ ] NumberFormatter+Extensions.swift exists and is in target

### Complications (1)
- [ ] CloudCryptoComplication.swift exists and is in target

## ✅ Final Checks

Before running:

- [ ] All 21 Swift files added to project
- [ ] All files have correct target membership
- [ ] Groups/folders organized properly
- [ ] Info.plist configured
- [ ] Capabilities enabled (Push Notifications, Background Modes)
- [ ] Signing configured
- [ ] Build succeeds without errors
- [ ] App runs in simulator

## 🎯 Next Steps

After all files are added:

1. **Build Project**: Press ⌘B
2. **Fix Errors**: Address any compiler errors
3. **Run App**: Press ⌘R
4. **Test Features**: Go through each screen
5. **Configure Backend**: Update API URL
6. **Test on Device**: Deploy to physical watch

---

## 📞 Need Help?

If you encounter issues:

1. **Check Console**: Xcode console shows build errors
2. **Clean Build**: ⌘⇧K then ⌘B
3. **Restart Xcode**: Sometimes needed after adding many files
4. **Check Documentation**: Refer to Setup-And-Deployment.md
5. **Verify Swift Version**: Ensure Xcode 15+ with Swift 5.9+

---

**Last Updated**: November 20, 2025

**Checklist Version**: 1.0.0
