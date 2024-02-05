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
