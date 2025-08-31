class OtpMailer < ApplicationMailer
  def otp_email(email, otp_code)
    @otp_code = otp_code
    mail(to: email, subject: 'Your One-Time Password (OTP)')
  end
end
