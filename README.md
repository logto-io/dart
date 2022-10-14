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

### Basic Use

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
| resources | List&#60;String&#62;? | List all the (resource indicators)[https://docs.logto.io/docs/references/resources/] you app may request for access. You may define and find it through Logto's admin console. |

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
