ActionMailer::Base.smtp_settings = {
  address: Rails.application.credentials.dig(:AWS, :SMTP_SERVER),
  port: Integer(ENV.fetch("SMTP_PORT", 587)),
  domain: Rails.application.domain,
  enable_starttls_auto: (ENV["SMTP_STARTTLS_AUTO"] == "true"),
  authentication: :login,
  user_name: Rails.application.credentials.dig(:AWS, :SMTP_USERNAME),
  password: Rails.application.credentials.dig(:AWS, :SMTP_PASSWORD),
}