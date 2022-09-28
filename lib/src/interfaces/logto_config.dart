class LogtoConfig {
  final String endpoint;
  final String appId;
  final String? appSecret;
  final List<String>? scopes;
  final List<String>? resources;

  const LogtoConfig({
    required this.appId,
    required this.endpoint,
    this.appSecret,
    this.resources,
    this.scopes,
  });
}
