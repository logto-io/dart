const Map<String, dynamic> mockOidcConfigResponse = {
  "authorization_endpoint": "https://logto.dev/oidc/auth",
  "code_challenge_methods_supported": ["S256"],
  "end_session_endpoint": "https://logto.dev/oidc/session/end",
  "grant_types_supported": ["implicit", "authorization_code", "refresh_token"],
  "issuer": "https://logto.dev/oidc",
  "jwks_uri": "https://logto.dev/oidc/jwks",
  "token_endpoint": "https://logto.dev/oidc/token",
  "userinfo_endpoint": "https://logto.dev/oidc/me",
  "revocation_endpoint": "https://logto.dev/oidc/token/revocation",
};

const Map<String, dynamic> mockCodeTokenResponse = {
  "access_token": "access_token",
  "refresh_token": "refresh_token",
  "id_token": "id_token",
  "scope": "profile offline_access openid",
  "expires_in": 1661840195980
};

const Map<String, dynamic> mockRefreshTokenResponse = {
  "access_token": "access_token",
  "refresh_token": "refresh_token",
  "id_token": "id_token",
  "scope": "profile offline_access openid",
  "expires_in": 1661840195980
};

const Map<String, dynamic> mockUserInfoResponse = {
  "sub": "foo",
  "username": "username",
  "name": "name",
  "picture": "http://avatar.png",
  "email": "foo@logto.io",
  "email_verified": true,
  "phone_number": "123456789",
  "phone_number_verified": true,
  "custom_data": {},
  "identities": {
    "google": {"id": "google_id", "email": "foo@google.com"},
  },
  "user_roles": ["user"]
};
