/// Xplor Pay (Clearent) environment credentials — TEST/sandbox (gateway-int).
///
/// USER DECISION (2026-10-29): compiled into the app on purpose ("set this in
/// env in app and use it") so field agents never type keys on-screen. The
/// correct base URL for this key is the sandbox INT gateway, which is what
/// `XplorPayEnv.sandbox` maps to.
///
/// SECURITY: production must never ship keys this way — move behind a
/// backend-issued token / proxy before the production release.
class XplorPayCredentials {
  static const String apiKey = '4d080b6ff15148d0a8c8a2ee2b3dc128';
  static const String publicKey =
      '307a301406072a8648ce3d020106092b240303020801010c036200041f9fb130f436ae5aac4a3ec5f02a98c6097ef7ed7367a7390789c789eabbfcdaa25ce531a5e03dc840ee8c4142375fcc65658431b21d4ef483eaa7611a4775076c944b06ad4bcd8629fbf4cb1549d000ff9760c2f5177771b37ab371b24dc693';

  /// These TEST credentials are provisioned on the sandbox INT gateway only
  /// (user-confirmed). Pinned here so a stale `xplorpay_env` pref can never
  /// route the TEST key to production (result code 9 = env mismatch).
  static const String baseUrl = 'https://gateway-int.clearent.net';
  static const bool isSandbox = true;
}
