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
