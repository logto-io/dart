<p align="center">
  <a href="https://logto.io" target="_blank" align="center" alt="Logto Logo">
      <img src="./logo.png" width="100">
  </a>
  <br/>
  <span><i><a href="https://logto.io" target="_blank">Logto</a> helps you quickly focus on everything after signing in.</i></span>
</p>

# Logto Flutter SDK

[![Build Status](https://github.com/logto-io/dart/actions/workflows/main.yml/badge.svg)](https://github.com/logto-io/dart/actions/workflows/main.yml)

This project is the official Flutter SDK for [Logto](https://logto.io). It provides a simple way to integrate Logto into your Flutter project.

In the background, this SDK uses the [flutter_web_auth_2](https://pub.dev/packages/flutter_web_auth_2) package to handle the OAuth2 flow.

## Installation

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  logto_dart_sdk: ^4.0.0
```

Then run `flutter pub get` to install the package.

Or directly install the package by running:

```bash
flutter pub add logto_dart_sdk
```

Check out the package on [pub.dev](https://pub.dev/packages/logto_dart_sdk).

## Setup

Check [Minimum requirements](#minimum-requirements) first — this SDK requires Flutter 3.35.0+
and, on Android, AGP 8.9.1+ with `compileSdk 36` and `minSdkVersion 24`.

- **iOS**: no additional setup required.
- **Android**: register the callback activity in your `AndroidManifest.xml` and set
  `android:taskAffinity=""` on your exported activities — see
  [Upgrading from 3.x to 4.0](#upgrading-from-3x-to-40) for the exact snippets, or the
  [flutter_web_auth_2 Android notes](https://github.com/ThexXTURBOXx/flutter_web_auth_2?tab=readme-ov-file#android).
- **Web**: serve a callback endpoint that posts the result back to the app — see the
  [flutter_web_auth_2 web notes](https://github.com/ThexXTURBOXx/flutter_web_auth_2?tab=readme-ov-file#web).

The [example app](./example) is a complete working reference for all three platforms.
Learn more about the [flutter_web_auth_2 setup](https://github.com/ThexXTURBOXx/flutter_web_auth_2?tab=readme-ov-file#setup).

## Usages

### Init Logto SDK

```dart
  final logtoConfig = const LogtoConfig(
    endpoint: "<your-logto-endpoint>",
    appId: "<your-app-id>"
  );

  void _init() {
    logtoClient = LogtoClient(
      config: logtoConfig,
      httpClient: http.Client(), // Optional http client
    );
    render();
  }
```

### Sign in and sign out

```dart
  // Sign in
  await logtoClient.signIn(redirectUri);

  // Sign out
  await logtoClient.signOut(redirectUri);
```

### Full SDK documentation

Check [Flutter SDK guide](https://docs.logto.io/quick-starts/flutter) for more details.

## Supported platforms

iOS, Android, Web

## Minimum requirements

| Requirement | Version |
| ----------- | ------- |
| Dart SDK    | 3.9.0   |
| Flutter     | 3.35.0  |
| Android Gradle Plugin | 8.9.1 |
| Android     | `compileSdk 36`, `minSdkVersion 24` |
| iOS         | 13.0    |
| macOS       | 10.15   |

The Android floor is set by `flutter_web_auth_2` 5.x, which compiles against SDK 36 and pulls
`androidx.browser:browser:1.9.0` (`minCompileSdk=36`, `minAndroidGradlePluginVersion=8.9.1`).
Flutter 3.35.0 is the first release whose template ships AGP 8.9.1 and defaults
`flutter.compileSdkVersion` to 36, so earlier Flutter versions fail at
`:app:checkDebugAarMetadata` even though the Dart-level constraints resolve.

The iOS and macOS floors are set by Flutter 3.35 itself, not by the plugins — Flutter 3.35
targets iOS 13.0 / macOS 10.15, while the plugins allow lower (`flutter_secure_storage`
iOS 12.0 / macOS 10.14, `flutter_web_auth_2` iOS 11.0 / macOS 10.15). Building on a newer
Flutter raises these further (3.47 targets iOS 15.0 / macOS 12.0); that follows from the
Flutter version you choose, not from this SDK.

**iOS 17.4 / macOS 14.4 are only required for HTTPS (universal link) callbacks.**
`flutter_web_auth_2` gates `ASWebAuthenticationSession.Callback` behind
`#available(iOS 17.4, *)` / `#available(macOS 14.4, *)` and falls back to the
`callbackURLScheme:` initializer below those versions. This SDK passes `callbackUrlScheme`,
so a custom-scheme redirect such as `io.logto://callback` works on the floors above.

## Migration guide

### Upgrading from 3.x to 4.0

**No Dart API changed, and your users stay signed in.** `signIn`, `signOut` and the rest keep
their 3.x signatures, and tokens stored by 3.x are migrated to the new encrypted format the
first time they are read, so nobody is forced to re-authenticate. The work is in your app's
Android toolchain configuration.

1. Update the dependency:

   ```yaml
   dependencies:
     logto_dart_sdk: ^4.0.0
   ```

2. Update Flutter and Dart to at least the versions in [Minimum requirements](#minimum-requirements)
   (Flutter 3.35.0 / Dart 3.9.0).

3. Use Android Gradle Plugin 8.9.1 or newer, in `android/settings.gradle`:

   ```groovy
   plugins {
       id "com.android.application" version "8.9.1" apply false
   }
   ```

4. Make sure `android/app/build.gradle` resolves to `compileSdk 36` and `minSdk 24`. On
   Flutter 3.35+ the Flutter defaults already do, so **if you use them, no change is
   needed**:

   ```groovy
   android {
       compileSdk = flutter.compileSdkVersion  // 36 on Flutter 3.35+

       defaultConfig {
           minSdk = flutter.minSdkVersion      // 24 on Flutter 3.35+
       }
   }
   ```

   If you pin either value explicitly, raise it:

   ```groovy
   android {
       compileSdk = 36

       defaultConfig {
           minSdk = 24
       }
   }
   ```

5. Add `android:taskAffinity=""` to every exported activity in
   `android/app/src/main/AndroidManifest.xml` — both your `MainActivity` and the
   `flutter_web_auth_2` `CallbackActivity`. This is strongly advised by `flutter_web_auth_2`
   5.x; without it the sign-in callback can return to the wrong task:

   ```xml
   <activity
       android:name=".MainActivity"
       android:exported="true"
       android:launchMode="singleTop"
       android:taskAffinity="">
       <!-- ... -->
   </activity>

   <activity
       android:name="com.linusu.flutter_web_auth_2.CallbackActivity"
       android:exported="true"
       android:launchMode="singleTop"
       android:taskAffinity="">
       <!-- ... -->
   </activity>
   ```

See the [example app](./example/android) for a complete working configuration — but note it
targets AGP 9, so it does not apply `kotlin-android`. On AGP 8.x you still need that plugin in
`android/app/build.gradle`; only remove it once you move to AGP 9 and Flutter's built-in Kotlin
support. See Flutter's
[built-in Kotlin migration guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers).

#### A note on Android Gradle Plugin 9

AGP 9 removed support for plugins applying the Kotlin Gradle Plugin (KGP). That is what this
release addresses: `flutter_secure_storage` 10.x no longer applies KGP, so it no longer blocks
AGP 9 builds.

`flutter_web_auth_2` 5.x still applies KGP. Builds currently succeed because Flutter ships
temporary KGP compatibility, and you will see this warning during the build:

```
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): flutter_web_auth_2
```

That warning is expected and harmless for now. Full AGP 9 support requires `flutter_web_auth_2`
6.x, which is still in alpha at the time of writing; this SDK will adopt it once it is stable.

### Upgrading to 3.0.0 from a version before 3.0.0

:::note
For SDK versions before 3.0.0, this SDK uses the [flutter_web_auth](https://pub.dev/packages/flutter_web_auth) package.
:::

1. Upgrade to the latest version

```yaml
dependencies:
  logto_dart_sdk: ^4.0.0
```

2. Update the manifest files (Android platform only)

Replace the flutter_web_auth callback activity with the new `flutter_web_auth_2` in the AndroidManifest.xml file.

- FlutterWebAuth -> FlutterWebAuth2
- flutter_web_auth -> flutter_web_auth_2

3. `redirectUri` parameter is now required for the `signOut` method.

```dart
await logtoClient.signOut(redirectUri);
```
