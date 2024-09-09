## 0.0.1

### Packages

| Name         | Description                                                                                                 |
| ------------ | ----------------------------------------------------------------------------------------------------------- |
| logto_core   | Core SDK is used for generation dart project with basic API and util method provided.                       |
| logto_client | Client SDK for flutter native apps. Built based on logto_core with user sign-in interaction flow integrated |

### Platforms

iOS, Android

### Features

- User sign-in using Logto's webAuth
- User sign-out
- Retrieve idToken claims
- Retrieve access token

## 1.0.0

### logto_client

- Support RBAC
- Add `LogtoClient.getUserInfo` to get authenticated user info

## 1.1.0

- fix Logto sign-out bug, the token revoke endpoint was misconfigured
- bump version to support Flutter 3.10
- bump the http dependency to the latest version
- bump the flutter_web_auth dependency to the latest version
- bump the flutter_secure_storage dependency to the latest version

## 1.2.0

### Dependencies update

- bump http package dependency to 1.2.0
- bump flutter_secure_storage package dependency to 9.0.0
- bump flutter_lints package dependency to 3.0.x

### Features

- Update `LogtoConfig` to support new organization feature, including new organization scopes and fetching organization token
- Add `LogtoClient.getOrganizationToken` method to support organization token retrieval

### Refactor

- Export all the necessary classes and interfaces from `logto_core` to `logto_client` package
- Update the example app to demonstrate the new organization feature

## 2.0.0

Upgrade to dart 3.0.0

- Fix the `UserInfo` abstract class used as mixin incompatibility issue
- SDK now supports Dart ^3.0.0
- < 3.0.0 users please use the previous version of the SDK

## 2.0.1

Bug fix

Issue: `LogtoClient.getUserInfo` method throws an `not authenticated` error when the initial access token is expired.
Expected behavior: The method should refresh the access token and return the user info properly.
Fix: Always get the access token by calling `LogtoClient.getAccessToken`, which will refresh the token automatically if it's expired.

## 2.0.2

Bug fix

Fix the `OpenIdClaims` class key parsing issue:

- `avatar` key is now `picture` mapped from the `picture` key in the token claims
- `phone` key is now `phoneNumber` mapped from the `phone_number` key in the token claims
- `phoneVerified` key is now `phoneNumberVerified` mapped from the `phone_number_verified` key in the token claims

Previous key mapping values are always empty as they are not available in the IdToken claims.
This fix update the key mapping to the correct values.

## 2.1.0

### New Features

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

### Bug Fixes

Fix the `logtoClient.getAccessToken` method always fetching new access token bug.

Background:
On each token exchange request, Logto dart SDK will cache the token response in the local storage. To reduce the number of token exchange requests, the SDK should always return the cached access token if it's not expired. Only when the access token is expired, the SDK should fetch a new access token using the refresh token.
However, the current implementation always fetches a new access token even if the cached access token is not expired.

Root cause:
Previously, all the access token storage keys are generated using the combination of the token's `resource`, `organization` and `scopes` values. This is to ensure that multiple access tokens can be stored in the storage without conflict.
Logto does not support narrowing down the scopes during a token exchange request, so the scopes value is always the same as the initial token request, therefore `scopes` is not necessary to be included in the `logtoClient.getAccessToken` method. Without the `scopes` value specified, the SDK can not locate the correct access token in the storage, which leads to always fetching a new access token.

Fix:
Remove the `scope` parameter from the `_tokenStorage.buildAccessTokenKey` and `_tokenStorage.getAccessToken` methods. Always get and set the access token using the `resource` and `organization` values as the key.
