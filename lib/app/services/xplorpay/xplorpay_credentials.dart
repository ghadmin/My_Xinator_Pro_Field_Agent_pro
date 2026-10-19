/// Static Xplor Pay credentials for this build (provided by Xplor Pay
/// onboarding for Mobile SDK testing).
///
/// SECURITY: these are TEST credentials baked into the client. Before
/// production, move the api-key behind your own backend (see
/// docs/xplorpay/README.md "Security notes") — the device should never hold
/// production gateway credentials.
class XplorPayCredentials {
  /// Gateway REST calls (`api-key` header).
  static const String apiKey = '4d080b6ff15148d0a8c8a2ee2b3dc128';

  /// SDK encryption key for the card reader.
  static const String publicKey =
      '307a301406072a8648ce3d020106092b240303020801010c036200041f9fb130f436ae5aac4a3ec5f02a98c6097ef7ed7367a7390789c789eabbfcdaa25ce531a5e03dc840ee8c4142375fcc65658431b21d4ef483eaa7611a4775076c944b06ad4bcd8629fbf4cb1549d000ff9760c2f5177771b37ab371b24dc693';
}
