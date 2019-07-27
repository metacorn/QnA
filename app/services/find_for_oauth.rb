module Services
  class FindForOauth
    attr_reader :auth

    def initialize(auth)
      @auth = auth
    end

    def call
      if auth.respond_to?(:include?) && auth.include?(:provider) && auth.include?(:uid)
        if authorization = Authorization.where(provider: auth.provider, uid: auth.uid.to_s).first
          authorization.user
        else
          user_with_new_authorization
        end
      else
        nil
      end
    end

    private

    def user_with_new_authorization
      email = auth.info.email
      user = User.find_by(email: email)
      if user
        create_authorization(user)
      else
        password = Devise.friendly_token[0, 20]
        user = User.new(email: email, password: password, password_confirmation: password)
        if email
          user.skip_confirmation!
          user.save!
          create_authorization(user)
        end
      end
      user
    end

    def create_authorization(user)
      user.authorizations.create!(provider: auth.provider,
                                  uid: auth.uid.to_s,
                                  oauth_email: auth.info.email,
                                  confirmed_at: Time.now)
    end
  end
end
