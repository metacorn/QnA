module OmniauthMacros
  def mock_auth_hash(provider:, email: 'mock@user.com', validness: true)
    if validness == true
      OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new ({
        'provider' => provider,
        'uid' => '123456',
        'info' => { 'email' => email }
      })
    else
      OmniAuth.config.mock_auth[provider] = :invalid_credentials
    end
  end
end
