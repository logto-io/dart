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
