class ForgotPasswordMailer < ApplicationMailer
  layout 'mailer'

  def forgot_password_email(email, password)
    @password = password
    mail(from:'venturebox@gmail.com', to: email, subject: "VentureBox password change")
  end
end
