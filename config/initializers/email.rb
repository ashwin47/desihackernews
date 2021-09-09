# ActionMailer::Base.smtp_settings = {
#   :address => ENV.fetch("SMTP_HOST", "127.0.0.1"),
#   :port => Integer(ENV.fetch("SMTP_PORT", 25)),
#   :domain => Rails.application.domain,
#   :enable_starttls_auto => (ENV["SMTP_STARTTLS_AUTO"] == "true"),
#   :user_name => ENV.fetch("SMTP_USERNAME", ""),
#   :password => ENV.fetch("SMTP_PASSWORD", ""),
# }

ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  :access_key_id     => Rails.application.credentials.dig(:AWS, :ACCESS_KEY),
  :secret_access_key => Rails.application.credentials.dig(:AWS, :SECRET_KEY),
  :signature_version => 4