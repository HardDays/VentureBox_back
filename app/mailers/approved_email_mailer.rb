class ApprovedEmailMailer < ApplicationMailer
  layout 'mailer'

  def investor_welcome_email(email, name)
    @name = name
    mail(from:'ventureboxreminder@gmail.com', to: email, subject: "Welcome to VentureBox")
  end

  def startup_welcome_email(email, name, password)
    @name = name
    @password = @password

    mail(from:'ventureboxreminder@gmail.com', to: email, subject: "Welcome to VentureBox")
  end
end
