class Twitter
  cattr_accessor :CONSUMER_KEY, :CONSUMER_SECRET, :AUTH_TOKEN, :AUTH_SECRET

  # these need to be overridden in config/initializers/production.rb
  @@CONSUMER_KEY = Rails.application.credentials.dig(:TWITTER, :CONSUMER_KEY)
  @@CONSUMER_SECRET = Rails.application.credentials.dig(:TWITTER, :CONSUMER_SECRET)

  # You'll need to go to https://apps.twitter.com/, add an app, and
  # whitelist both /settings and /settings/twitter_callback as Callback URLs
  # for users to be able to authenticate their Twitter accounts.

  # these are set for the account used to post updates in
  # script/post_to_twitter (needs read/write access)
  @@AUTH_TOKEN = #Rails.application.credentials.dig(:twitter, :AUTH_TOKEN)
  @@AUTH_SECRET = #Rails.application.credentials.dig(:twitter, :AUTH_SECRET)

  MAX_TWEET_LEN = 280

  # https://t.co/eyW1U2HLtP
  TCO_LEN = 23

  def self.enabled?
    self.CONSUMER_KEY.present?
  end

  def self.oauth_consumer
    OAuth::Consumer.new(self.CONSUMER_KEY, self.CONSUMER_SECRET, :site => "https://api.twitter.com")
  end

  def self.oauth_request(req, method = :get, post_data = nil)
    if !self.AUTH_TOKEN
      raise "no auth token configured"
    end

    begin
      Timeout.timeout(120) do
        at = OAuth::AccessToken.new(self.oauth_consumer, self.AUTH_TOKEN, self.AUTH_SECRET)

        if method == :get
          res = at.get(req)
        elsif method == :post
          res = at.post(req, post_data)
        else
          raise "what kind of method is #{method}?"
        end

        if res.class == Net::HTTPUnauthorized
          raise "not authorized"
        end

        if res.body.to_s == ""
          raise res.inspect
        else
          return JSON.parse(res.body)
        end
      end
    end
  end

  def self.token_secret_and_user_from_token_and_verifier(tok, verifier)
    rt = OAuth::RequestToken.from_hash(self.oauth_consumer, :oauth_token => tok)
    at = rt.get_access_token(:oauth_verifier => verifier)

    res = at.get("/1.1/account/verify_credentials.json?include_email=true")
    js = JSON.parse(res.body)

    if !js["screen_name"].present? || !js["email"].present?
      return nil
    end

    [at.token, at.secret, js["screen_name"], js["email"]]
  end

  def self.oauth_request_token(state, auth)
    if auth
      self.oauth_consumer.get_request_token(oauth_callback: Rails.application.root_url + "connected_accounts/twitter_callback?state=#{state}")
    else
      self.oauth_consumer.get_request_token(oauth_callback: Rails.application.root_url + "connected_accounts/twitter_connect_callback?state=#{state}")
    end
  end

  def self.oauth_auth_url(state, auth)
    self.oauth_request_token(state, auth).authorize_url
  end
end
