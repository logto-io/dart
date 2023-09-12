<p align="center">
  <a href="https://logto.io" target="_blank" align="center" alt="Logto Logo">
      <img src="./logo.png" width="100">
  </a>
  <br/>
  <span><i><a href="https://logto.io" target="_blank">Logto</a> helps you quickly focus on everything after signing in.</i></span>
</p>

# Logto Flutter SDKs

[![Build Status](https://github.com/logto-io/kotlin/actions/workflows/main.yml/badge.svg)](https://github.com/logto-io/dart/actions/workflows/main.yml)

Logto's flutter SDK for native apps.

## Installation

```sh
flutter pub get logto_dart_sdk
```

## Products

| Name         | Description                                                                                                 |
| ------------ | ----------------------------------------------------------------------------------------------------------- |
| logto_core   | Core SDK is used for generation dart project with basic API and util method provided.                       |
| logto_client | Client SDK for flutter native apps. Built based on logto_core with user sign-in interaction flow integrated |

## Logto Client

### Configurations

#### flutter_secure_storage

We use [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) to implement the cross-platform persistent auth_token secure storage.

- Keychain is used for iOS
- AES encryption is used for Android.

Configure Android version:

In [project]/android/app/build.gradle set minSdkVersion to >= 18.

```gradle
android {
    ...

    defaultConfig {
        ...
        minSdkVersion 18
        ...
    }
}

```

> Note By default Android backups data on Google Drive. It can cause exception java.security.InvalidKeyException:Failed to unwrap key. You need to:
>
> - disable autobackup,
> - exclude sharedprefs FlutterSecureStorage used by the plugin

1. To disable autobackup, go to your app manifest file and set the boolean value android:allowBackup.

```xml
<manifest ... >
    ...
    <application
      android:allowBackup="false"
      android:fullBackupContent="false">
      ...
    >
        ...
    </application>
</manifest>
```

2. Exclude sharedprefs FlutterSecureStorage.

If you need to enable the android:fullBackupContent for your app. Set up a backup rule to [exclude](https://developer.android.com/guide/topics/data/autobackup#IncludingFiles) the prefs used by the plugin.

```xml
<application ...
  android:fullBackupContent="@xml/backup_rules">
</application>
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
  <exclude domain="sharedpref" path="FlutterSecureStorage"/>
</full-backup-content>
```

Please check [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage#configure-android-version) for more details.

#### flutter_web_auth

[flutter_web_auth](https://pub.dev/packages/flutter_appauth) is used behind Logto's flutter SDK. We rely on its webview-based interaction interface to open Logto's authorization pages.

> In the background, this plugin uses ASWebAuthenticationSession on iOS 12+ and macOS 10.15+, SFAuthenticationSession on iOS 11, Chrome Custom Tabs on Android and opens a new window on Web. You can build it with iOS 8+, but it is currently only supported by iOS 11 or higher.

Android

In order to capture the callback url from Logto's sign-in web page, you will need to register your sign-in redirectUri to the `AndroidManifest.xml`.

```xml
<activity android:name="com.linusu.flutter_web_auth.CallbackActivity" android:exported="true">
    <intent-filter android:label="flutter_web_auth">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="io.logto"/>
    </intent-filter>
</activity>
```

By doing so, your app will automatically capture the callbaclUri after a successful sign-in and redirect the user back to the app.

### Basic Usage

```dart
import 'package:logto_dart_sdk/logto_dart_sdk.dart';

// ...
late LogtoClient logtoClient;

void _init() async  {
  logtoClient = LogtoClient(
    config: config, // LogtoConfig
    httpClient: http.Client(), // Optional http client
  );
}

void signIn() async {
  await logtoClient.signIn(redirectUri);
}

void signOut() async {
  await logtoClient.signOut();
}

```

### Class LogtoConfig

#### Properties

| name      | type                  | description                                                                                                                                                                    |
| --------- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| appId     | String                | Your appId generate from Logto's admin console                                                                                                                                 |
| appSecret | String?               | App Secret generated along with the appId. Optional for native apps.                                                                                                           |
| endpoint  | String                | Your logto server endpoint. e.g. https://logto.dev                                                                                                                             |
| scopes    | List&#60;String&#62;? | List all the permission scopes your app will request for. You may define and find it through Logto's admin console.                                                            |
| resources | List&#60;String&#62;? | List all the [resource indicators](https://docs.logto.io/docs/references/resources/) you app may request for access. You may define and find it through Logto's admin console. |

### Class LogtoClient

#### Properties

| name            | type                                    | description                                     |
| --------------- | --------------------------------------- | ----------------------------------------------- |
| config          | final LogtoConfig                       | Logto Config used to init Logto Client          |
| idToken         | read-only Future&#60;String?&#62;       | idToken returned after success authentication   |
| isAuthenticated | read-only Future&#60;bool&#62;          | Is Authenticated status                         |
| idTokenClaims   | read-only Future&#60;OpenIdClaims?&#62; | Decoded idToken claims including basic userinfo |
| loading         | read-only bool                          | Global API loading status                       |

#### Methods

| name           | type                                                | description                                                         |
| -------------- | --------------------------------------------------- | ------------------------------------------------------------------- |
| getAccessToken | ({String? resource}) -> Future&#60;AccessToken&#62; | Request for an api resource specific access token for authorization |
| signIn         | (String? redirectUri) -> Future&#60;void&#62;       | Init user sign-in flow                                              |
| signOut        | () -> Future&#60;void&#62;                          | Sign-out                                                            |
| getUserInfo    | () => Future&#60;UserInfo&#62;                      | Get user info                                                       |
