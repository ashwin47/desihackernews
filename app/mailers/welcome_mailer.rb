class WelcomeMailer < ApplicationMailer
  def welcome(user)
    @user = user

    mail(
      to: user.email,
      subject: "[#{Rails.application.name}] Welcome to " <<
               Rails.application.name
    )
  end
end
