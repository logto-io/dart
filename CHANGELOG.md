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
