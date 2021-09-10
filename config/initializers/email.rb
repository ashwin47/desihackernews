ActionMailer::Base.smtp_settings = {
  address: Rails.application.credentials.dig(:AWS, :SMTP_SERVER),
  port: 587,
  domain: Rails.application.domain,
  enable_starttls_auto: true,
  tls: false,
  ssl: false,
  user_name: Rails.application.credentials.dig(:AWS, :SMTP_USERNAME),
  password: Rails.application.credentials.dig(:AWS, :SMTP_PASSWORD),
}