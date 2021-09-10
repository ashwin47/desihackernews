class ApplicationMailer < ActionMailer::Base
  default :from => "#{Rails.application.name} <no-reply@hackernews.desi>"
end
