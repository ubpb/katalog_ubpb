class OrderMailer < ApplicationMailer

  default from: "ortsleihe@ub.uni-paderborn.de"

  def notify_staff
    @order = params[:order]
    mail(to: "r.sprotte@ub.uni-paderborn.de", subject: "Neue Medienbestellung")
  end

  def confirm_user
    @order = params[:order]
    email  = @order.user.email_address

    if email.present?
      mail(to: email, subject: "Bestätigung Medienbestellung")
    end
  end

end
