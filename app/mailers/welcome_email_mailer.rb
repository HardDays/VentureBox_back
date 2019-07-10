class WelcomeEmailMailer < ApplicationMailer
  layout 'mailer'

  def welcome_email(email, name)
    @name = name
    mail(from:'ventureboxreminder@gmail.com', to: email, subject: "Welcome to VentureBox")
  end
end
