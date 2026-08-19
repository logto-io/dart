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

- iOS: No additional setup required.
- [Android](https://github.com/ThexXTURBOXx/flutter_web_auth_2?tab=readme-ov-file#android).
- [Web](https://github.com/ThexXTURBOXx/flutter_web_auth_2?tab=readme-ov-file#web)

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

:::note
For SDK version before 3.0.0, this SDK uses the [flutter_web_auth](https://pub.dev/packages/flutter_web_auth) package.
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
