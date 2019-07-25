module Services
  class FindForOauth
    attr_reader :auth

    def initialize(auth)
      @auth = auth
    end

    def call
      authorization = Authorization.where(provider: auth.provider, uid: auth.uid.to_s).first
      return authorization.user if authorization

      user_with_new_authorization
    end

    private

    def user_with_new_authorization
      email = auth.info.email
      user = User.find_by(email: email)
      if user
        create_authorization(user)
      else
        password = Devise.friendly_token[0, 20]
        user = User.create!(email: email, password: password, password_confirmation: password)
        create_authorization(user)
      end
      user
    end

    def create_authorization(user)
      user.authorizations.create(provider: auth.provider, uid: auth.uid.to_s)
    end
  end
end
