#  Project Setup

## Using the Static Framework

1. Open `Nexum.xcodeproj`
2. Build the  `Framework` target for  `Generic iOS Device`
3. Navigate to the `{Repo}/Release` directory and copy `Nexum.framework` into your project directory
4. Go to your App target's settings, and go to the `General` tab`General`
5. Click "+" under the `Linked Frameworks and Libraries`
6. Select `Add other...`
7. Choose `Nexum.framework`
8. Add `@import Nexum;` in the relevent classes in your app

## Using the Source Directly

1. Navigation to `{Repo}/Nexum/`
2. Copy `NXNetwork.h` and `NXNetwork.m` into your project directory
3. Open your Xcode project and right-click in the Navigator
4. Choose `Add files to {AppName}...`
5. Select `NXNetwork.h` and `NXNetwork.m`. Make sure `.m` file is linked to your target.
6. Add `#import 'NXNetwork.h'` in the relevent classes in your app

## Building The Documentaiton

1. Install [Jazzy](https://github.com/realm/jazzy)
2. Delete the `{Repo}/Release` directory if it exists
3. Open `Nexum.xcodeproj`
4. Build the  `Documentation` target for  `Generic iOS Device`
