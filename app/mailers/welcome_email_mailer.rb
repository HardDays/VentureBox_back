class WelcomeEmailMailer < ApplicationMailer
  layout 'mailer'

  def welcome_email(email, name)
    mail(from:'ventureboxreminder@gmail.com', to: email, subject: "Welcome to VentureBox", name: name)
  end
end
