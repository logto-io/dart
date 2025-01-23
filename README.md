<p align="center">
  <a href="https://logto.io" target="_blank" align="center" alt="Logto Logo">
      <img src="./logo.png" width="100">
  </a>
  <br/>
  <span><i><a href="https://logto.io" target="_blank">Logto</a> helps you quickly focus on everything after signing in.</i></span>
</p>

# Logto Flutter SDK

[![Build Status](https://github.com/logto-io/kotlin/actions/workflows/main.yml/badge.svg)](https://github.com/logto-io/dart/actions/workflows/main.yml)

This project is the official Flutter SDK for [Logto](https://logto.io). It provides a simple way to integrate Logto into your Flutter project.

In the background, this SDK uses the [flutter_web_auth_2](https://pub.dev/packages/flutter_web_auth_2) package to handle the OAuth2 flow.

## Installation

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  logto_dart_sdk: ^3.0.0
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

## Migration guide

:::note
For SDK version before 3.0.0, this SDK uses the [flutter_web_auth](https://pub.dev/packages/flutter_web_auth) package.
:::

1. Upgrade to the latest version

```yaml
dependencies:
  logto_dart_sdk: ^3.0.0
```

2. Update the manifest files (Android platform only)

Replace the flutter_web_auth callback activity with the new `flutter_web_auth_2` in the AndroidManifest.xml file.

- FlutterWebAuth -> FlutterWebAuth2
- flutter_web_auth -> flutter_web_auth_2

3. `redirectUri` parameter is now required for the `signOut` method.

```dart
await logtoClient.signOut(redirectUri);
```
