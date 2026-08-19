## 4.0.0

Modernizes the dependency stack so apps keep building on recent Flutter and Android
toolchains. **No Dart API changed in this release, and existing users stay signed in** —
tokens stored by `3.x` are migrated automatically on first read.

### What you need to do

All of the required work is in your app's Android configuration. See the
[3.x to 4.0 migration guide](https://github.com/logto-io/dart#upgrading-from-3x-to-40)
for copy-pasteable snippets.

| Change | Where |
| ------ | ----- |
| Flutter `>=3.35.0`, Dart `^3.9.0` | your toolchain |
| Android Gradle Plugin `>=8.9.1` | `android/settings.gradle` |
| `compileSdk 36`, `minSdk 24` — both are the Flutter 3.35+ defaults, so no change if you use them | `android/app/build.gradle` |
| `android:taskAffinity=""` on exported activities | `android/app/src/main/AndroidManifest.xml` |

Upgrading from a version before `3.0.0` lands you on `4.0.0` directly, so the
[pre-3.0 migration steps](https://github.com/logto-io/dart#upgrading-from-a-version-before-300)
(manifest rename, `signOut` now requiring `redirectUri`) apply **in addition to** the table
above — not instead of it.

### Dependencies update

Starting with Android Gradle Plugin (AGP) 9.0, applying the Kotlin Gradle Plugin (KGP) from a
plugin is no longer supported, which breaks builds that depend on older plugin versions.
([Flutter migration guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin))

1. Bump `flutter_secure_storage` from `^9.0.0` to `^10.3.1`

   - `10.x` no longer applies the Kotlin Gradle Plugin, which is what unblocks AGP 9 builds.
   - The Android implementation no longer uses the deprecated Jetpack `encryptedSharedPreferences` backend. Tokens written by SDK `3.x` are read and migrated to the new AES-GCM cipher storage on first access, since `migrateOnAlgorithmChange` defaults to true. Existing users stay signed in across the upgrade.
   - Android now requires `minSdkVersion` 24 (`flutter_secure_storage` needs 23; `flutter_web_auth_2` and the Flutter 3.35 default raise it to 24).

   > **Note**: this SDK intentionally stays on `flutter_secure_storage` `10.x` rather than `11.x`. The `11.x` release removed the `EncryptedSharedPreferences` backend outright, so upgrading directly from `9.x` to `11.x` makes tokens written by SDK `3.x` unreadable and silently signs existing Android users out — verified on a device, where the same read returns `null` under `11.0.0` and the original value under `10.3.1`. `10.x` is the migration bridge, and `tool/test_token_migration.sh` guards it. A future major release will move to `11.x` once users have had a release to migrate through; note that the bridge only helps users who actually run a `4.x` release, so anyone upgrading `3.x` straight to that future major would still be signed out.

2. Bump `flutter_web_auth_2` from `^4.1.0` to `^5.1.0`

   - This plugin does not raise the iOS or macOS deployment floor: its podspecs still target iOS 11.0 / macOS 10.15. The SDK's floors of iOS 13.0 / macOS 10.15 come from Flutter 3.35 itself. iOS 17.4 / macOS 14.4 are needed only for HTTPS (universal link) callbacks — `flutter_web_auth_2` gates `ASWebAuthenticationSession.Callback` behind `#available` and falls back to the `callbackURLScheme:` initializer below those versions, which is the path this SDK uses with `callbackUrlScheme`.
   - It is strongly advised to set `android:taskAffinity=""` on all exported activities (including your `MainActivity` and the `flutter_web_auth_2` `CallbackActivity`) in the AndroidManifest.xml file. See the updated example app.

3. Bump `jose` to `^0.3.5+1`, which resolves [GHSA-vm9r-h74p-hg97](https://github.com/advisories/GHSA-vm9r-h74p-hg97) (untrusted JWK header key acceptance during signature verification). This SDK uses `jose` to verify ID tokens, so the dependency floor is raised rather than only the lockfile.

4. Require Dart SDK `^3.9.0` and Flutter `>=3.35.0`.

   This floor is set by the Android toolchain, not by the Dart-level constraints. `flutter_web_auth_2` `5.1.0` compiles against SDK 36 and depends on `androidx.browser:browser:1.9.0`, whose AAR metadata declares `minCompileSdk=36` and `minAndroidGradlePluginVersion=8.9.1`. Flutter `3.35.0` is the first release whose template ships AGP `8.9.1` and defaults `flutter.compileSdkVersion` to 36; on Flutter `3.24` (template AGP `7.3.0`, `compileSdk 34`) the build fails at `:app:checkDebugAarMetadata`. Apps that pin their own AGP must be on `8.9.1+` with `compileSdk 36`.

> **Note**: `flutter_web_auth_2` `5.x` still applies the Kotlin Gradle Plugin on Android, so it does not yet build with AGP 9. Flutter's temporary KGP compatibility keeps it working on current Flutter releases. Full AGP 9 support lands in `flutter_web_auth_2` `6.x` (in alpha at the time of writing), which we will adopt once it is stable.

## 3.0.0

### Dependencies update

1. Switch to flutter_web_auth_2 package
   Replace the legacy [flutter_web_auth](https://pub.dev/packages/flutter_web_auth) package with the new [flutter_web_auth_2](https://pub.dev/packages/flutter_web_auth_2). Since the `flutter_web_auth` package is no longer maintained, we have to switch to the new package to support the latest Flutter versions.

   **flutter_web_auth_2** setup guide:

   - iOS: No additional setup required
   - Android: In order to capture the callback URL. You wil need to add the following activity to your AndroidManifest.xml file. Replace `YOUR_CALLBACK_URL_SCHEME_HERE` with your actual callback URL scheme (io.logto etc.).

     ```xml
     <manifest>
      <application>

         <activity
            android:name="com.linusu.flutter_web_auth_2.CallbackActivity"
            android:exported="true">
            <intent-filter android:label="flutter_web_auth_2">
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="YOUR_CALLBACK_URL_SCHEME_HERE" />
            </intent-filter>
         </activity>

      </application>
      </manifest>
     ```

     Remove any `android:taskAffinity` entries and add set `android:launchMode="singleTop"` to the main activity in the AndroidManifest.xml file.

   - Web: Create a new endpoint to capture the callback URL and sent it back to the application using `postMessage` API. The endpoint should be the same as the `redirectUri` parameter in the `signIn` method.

     ```html
     <!DOCTYPE html>
     <title>Authentication complete</title>
     <p>
       Authentication is complete. If this does not happen automatically, please
       close the window.
     </p>
     <script>
       function postAuthenticationMessage() {
         const message = {
           "flutter-web-auth-2": window.location.href,
         };

         if (window.opener) {
           window.opener.postMessage(message, window.location.origin);
           window.close();
         } else if (window.parent && window.parent !== window) {
           window.parent.postMessage(message, window.location.origin);
         } else {
           localStorage.setItem("flutter-web-auth-2", window.location.href);
           window.close();
         }
       }

       postAuthenticationMessage();
     </script>
     ```

     Please check the setup guide in the [flutter_web_auth_2](https://pub.dev/packages/flutter_web_auth_2#setup) package for more details.

2. Other patches
   - bump crypto package
   - bump jose package
   - bump json_annotation package

### New features

1. With the latest `flutter_web_auth_2` package, this SDK now supports the Web platform. You can use Logto dart SDK in your Flutter web projects as well. Officially supported platforms are iOS, Android, and Web.

### Bug fixes

1. Fix the namespace missing issue when building with the latest Gradle version on Android. ([#75](https://github.com/logto-io/dart/issues/75))
2. Fix the issue that the webview is not closing after the user completes the OAuth2 authorization flow on Android. ([60](https://github.com/logto-io/dart/issues/60))
3. Fix the issue on Android that the sign-in session is not cleared after the user signs out.

### Breaking changes

`logtoClient.signOut` method now requires a `redirectUri` parameter. For iOS platform, this parameter is useless, but for Android and Web platforms which require an additional `end_session` request to clean up the sign-in session, this parameter will be used as the `post_logout_redirect_uri` parameter in the `end_session` request.

User experience on iOS will not be affected by this change, but for Android and Web platforms, when users click the sign-out button, an `end_session` request will be triggered by opening a webview with the `post_logout_redirect_uri` parameter set to the `redirectUri` value. This will clear the sign-in session and redirect the user back to the `redirectUri` page.

## 2.1.0

### New features

Add extra parameters to the signIn method for better sign-in experience customization.

See the [Authentication parameters](https://docs.logto.io/docs/references/openid-connect/authentication-parameters) for more details.

1. `directSignIn`: This parameter allows you to skip the first screen of the sign-in page and directly go to the social or enterprise sso connectors's sign-in page.

   - `social:<idp-name>`: Use the specified social connector, e.g. `social:google`
   - `sso:<connector-id>`: Use the specified enterprise sso connector, e.g. `sso:123456`

2. `firstScreen`: This parameter allows you to customize the first screen that users see when they start the authentication process. The value for this parameter can be:

   - `sign_in`: Allow users to directly access the sign-in page.
   - `register`: Allow users to directly access the registration page.
   - `single_sign_on`: Allow users to directly access the single sign-on (SSO) page.
   - `identifier:sign_in`: Allow users to direct access a page that only display specific identifier-based sign-in methods to users.
   - `identifier:register`: Allow users to direct access a page that only display specific identifier-based registration methods to users.
   - `reset_password`: Allow users to directly access the password reset page.

3. `identifiers`: Additional parameter to specify the identifier type for the first screen. This parameter is only used when the `firstScreen` parameter is set to `identifier:sign_in`, `identifier:register` or `reset_password`. The value can be a list of the following supported identifier types:

   - `email`
   - `phone`
   - `username`

4. `extraParams`: This parameter allow you to pass additional custom parameters to the Logto sign-in page. The value for this parameter should be a Map<String, String> object.

### Bug fixes

Fix the `logtoClient.getAccessToken` method always fetching new access token bug.

Background:
On each token exchange request, Logto dart SDK will cache the token response in the local storage. To reduce the number of token exchange requests, the SDK should always return the cached access token if it's not expired. Only when the access token is expired, the SDK should fetch a new access token using the refresh token.
However, the current implementation always fetches a new access token even if the cached access token is not expired.

Root cause:
Previously, all the access token storage keys are generated using the combination of the token's `resource`, `organization` and `scopes` values. This is to ensure that multiple access tokens can be stored in the storage without conflict.
Logto does not support narrowing down the scopes during a token exchange request, so the scopes value is always the same as the initial token request, therefore `scopes` is not necessary to be included in the `logtoClient.getAccessToken` method. Without the `scopes` value specified, the SDK can not locate the correct access token in the storage, which leads to always fetching a new access token.

Fix:
Remove the `scope` parameter from the `_tokenStorage.buildAccessTokenKey` and `_tokenStorage.getAccessToken` methods. Always get and set the access token using the `resource` and `organization` values as the key.

## 2.0.2

### Bug fixes

Fix the `OpenIdClaims` class key parsing issue:

- `avatar` key is now `picture` mapped from the `picture` key in the token claims
- `phone` key is now `phoneNumber` mapped from the `phone_number` key in the token claims
- `phoneVerified` key is now `phoneNumberVerified` mapped from the `phone_number_verified` key in the token claims

Previous key mapping values are always empty as they are not available in the IdToken claims.
This fix update the key mapping to the correct values.

## 2.0.1

### Bug fixes

Issue: `LogtoClient.getUserInfo` method throws an `not authenticated` error when the initial access token is expired.
Expected behavior: The method should refresh the access token and return the user info properly.
Fix: Always get the access token by calling `LogtoClient.getAccessToken`, which will refresh the token automatically if it's expired.

## 2.0.0

### Dependencies update

Upgrade to dart 3.0.0

- Fix the `UserInfo` abstract class used as mixin incompatibility issue
- SDK now supports Dart ^3.0.0
- < 3.0.0 users please use the previous version of the SDK

## 1.2.0

### Dependencies update

- bump http package dependency to 1.2.0
- bump flutter_secure_storage package dependency to 9.0.0
- bump flutter_lints package dependency to 3.0.x

### New features

- Update `LogtoConfig` to support new organization feature, including new organization scopes and fetching organization token
- Add `LogtoClient.getOrganizationToken` method to support organization token retrieval

### Refactors

- Export all the necessary classes and interfaces from `logto_core` to `logto_client` package
- Update the example app to demonstrate the new organization feature

## 1.0.0

### New features

- Support RBAC
- Add `LogtoClient.getUserInfo` method to get authenticated user info

## 0.0.1

### Packages

| Name         | Description                                                                                                 |
| ------------ | ----------------------------------------------------------------------------------------------------------- |
| logto_core   | Core SDK is used for generation dart project with basic API and util method provided.                       |
| logto_client | Client SDK for flutter native apps. Built based on logto_core with user sign-in interaction flow integrated |

### Supported Platforms

iOS, Android

### Features

- User sign-in using Logto's webAuth
- User sign-out
- Retrieve idToken claims
- Retrieve access token
