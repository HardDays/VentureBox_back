class WelcomeEmailMailer < ApplicationMailer
  layout 'mailer'

  def welcome_email(email, name)
    mail(from:'venturebox@gmail.com', to: email, subject: "Welcome to VentureBox", name: name)
  end
end
