/// Resources that reserved by Logto, which cannot be defined by users.
enum LogtoReservedResource {
  /// The resource for organization template per RFC 0001.
  /// @see {@link https://github.com/logto-io/rfcs | RFC 0001} for more details.
  organization
}

extension LogtoReservedResourceExtension on LogtoReservedResource {
  String get value {
    switch (this) {
      case LogtoReservedResource.organization:
        return 'urn:logto:resource:organizations';
      default:
        throw Exception("Invalid value");
    }
  }
}

/// Scopes for ID Token and Userinfo Endpoint.
enum LogtoUserScope {
  /// Scope for basic user profile. ['name', 'picture', 'username'],
  profile,

  /// Scope for user email.
  email,

  /// Scope for user phone.
  phone,

  /// Scope for user;s custom data.
  customData,

  /// Scope for user's social identity details
  identities,

  /// Scope for user's roles
  roles,

  /// Scope for user's organization IDs and perform organization token grant per [RFC 0001](https://github.com/logto-io/rfcs).
  organizations,
  organizationRoles,
}

extension LogtoUserScopeUserScopeExtension on LogtoUserScope {
  String get value {
    switch (this) {
      case LogtoUserScope.profile:
        return 'profile';
      case LogtoUserScope.email:
        return 'email';
      case LogtoUserScope.phone:
        return 'phone';
      case LogtoUserScope.customData:
        return 'custom_data';
      case LogtoUserScope.identities:
        return 'identities';
      case LogtoUserScope.roles:
        return 'roles';
      case LogtoUserScope.organizations:
        return 'urn:logto:scope:organizations';
      case LogtoUserScope.organizationRoles:
        return 'urn:logto:scope:organization_roles';
      default:
        throw Exception("Invalid value");
    }
  }
}
