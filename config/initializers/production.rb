# This template for a production-only config file of API tokens was taken and
# cleaned up from Lobsters.
#
# Copy this to config/initializers/production.rb and customize, it's already
# listed in .gitignore to help prevent you from accidentally committing it.
#
# This predates Rails' config/secrets.yml feature and we could probably shift
# to using that at some point.

if Rails.env.production?
  Lobsters::Application.config.middleware.use ExceptionNotification::Rack,
    :ignore_exceptions => [
      "ActionController::UnknownFormat",
      "ActionController::BadRequest",
      "ActionDispatch::RemoteIp::IpSpoofAttackError",
    ] + ExceptionNotifier.ignored_exceptions,
    :email => {
      :email_prefix => "[site] ",                    # fill in site name
      :sender_address => %{"Exception Notifier" <>}, # fill in from address
      :exception_recipients => %w{},                 # fill in destination addresses
    }

  Pushover.API_TOKEN = Rails.application.credentials.dig(:PUSHOVER, :API_TOKEN)
  Pushover.SUBSCRIPTION_CODE = Rails.application.credentials.dig(:PUSHOVER, :SUBSCRIPTION_CODE)

  DiffBot.DIFFBOT_API_KEY = Rails.application.credentials.dig(:DIFFBOT, :API_KEY)

  Twitter.CONSUMER_KEY = Rails.application.credentials.dig(:TWITTER, :CONSUMER_KEY)
  Twitter.CONSUMER_SECRET = Rails.application.credentials.dig(:TWITTER, :CONSUMER_SECRET)
  Twitter.AUTH_TOKEN = Rails.application.credentials.dig(:TWITTER, :AUTH_TOKEN)
  Twitter.AUTH_SECRET = Rails.application.credentials.dig(:TWITTER, :AUTH_SECRET)

  Github.CLIENT_ID = Rails.application.credentials.dig(:GITHUB, :CLIENT_ID)
  Github.CLIENT_SECRET = Rails.application.credentials.dig(:GITHUB, :CLIENT_SECRET)

  BCrypt::Engine.cost = 12

  Keybase.DOMAIN = Rails.application.domain
  Keybase.BASE_URL = ENV.fetch('KEYBASE_BASE_URL') { 'https://keybase.io' }

  ActionMailer::Base.delivery_method = :sendmail

  class << Rails.application
    def allow_invitation_requests?
      false
    end

    def allow_new_users_to_invite?
      true
    end

    def domain
      "hackernews.desi"
    end

    def name
      "DesiHackerNews"
    end

    def ssl?
      true
    end
  end
end
