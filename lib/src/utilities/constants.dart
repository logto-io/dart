Set<String> reservedScopes = {'openid', 'offline_access', 'profile'};

const String authorizationCodeGrantType = 'authorization_code';
const String refreshTokenGrantType = 'refresh_token';

const String discoveryPath = "/oidc/.well-known/openid-configuration";

/// The prefix of organization URN(Uniform Resource Name)for the organization in Logto.
/// @example urn:logto:organization:org_1234
///  @see {@link https://en.wikipedia.org/wiki/Uniform_Resource_Name | Uniform Resource Name}
const String organizationUrnPrefix = 'urn:logto:organization:';

/// Build the organization URN from organization ID.
///
/// @param organizationId The organization ID.
/// @return The organization URN.
String buildOrganizationUrn(String organizationId) =>
    '$organizationUrnPrefix$organizationId';

String getOrganizationIdFromUrn(String organizationUrn) {
  if (!organizationUrn.startsWith(organizationUrnPrefix)) {
    throw ArgumentError('Invalid organization URN.');
  }

  return organizationUrn.substring(organizationUrnPrefix.length);
}

/**
 * @Deprecated use firstScreen instead
 * 
 * By default Logto use sign-in as the landing page for the user.
 * Use this enum to specify the interaction mode.
 * 
 * - signIn: The user will be redirected to the sign-in page.
 * - signUp: The user will be redirected to the sign-up page.
 */
@Deprecated('Legacy parameter, use firstScreen instead')
enum InteractionMode { signIn, signUp }

extension InteractionModeExtension on InteractionMode {
  String get value {
    switch (this) {
      case InteractionMode.signIn:
        return 'signIn';
      case InteractionMode.signUp:
        return 'signUp';
      default:
        throw Exception("Invalid value");
    }
  }
}

/**
 * The first screen to be shown in the sign-in experience.
 * 
 * Note it's not a part of the OIDC standard, but a Logto-specific extension.
 */
enum FirstScreen {
  signIn,
  register,
  identifierSignIn,
  identifierRegister,
  singleSignOn,
}

extension FirstScreenExtension on FirstScreen {
  String get value {
    switch (this) {
      case FirstScreen.signIn:
        return 'sign_in';
      case FirstScreen.register:
        return 'register';
      case FirstScreen.identifierSignIn:
        return 'identifier:sign_in';
      case FirstScreen.identifierRegister:
        return 'identifier:register';
      case FirstScreen.singleSignOn:
        return 'single_sign_on';
      default:
        throw Exception("Invalid value");
    }
  }
}
