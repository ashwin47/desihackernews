class ApplicationMailer < ActionMailer::Base
  default :from => "#{Rails.application.name} <no-reply@#{Rails.application.domain}>"
end
