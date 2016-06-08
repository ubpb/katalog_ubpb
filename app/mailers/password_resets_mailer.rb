class PasswordResetsMailer < ApplicationMailer

  default from: "ortsleihe@ub.uni-paderborn.de"

  def notify_user(user)
    @user = user

    mail(to: @user.email_address, subject: "[UB Paderborn] Passwort zurücksetzen")
  end

end
