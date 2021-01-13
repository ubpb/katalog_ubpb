class OrderMailer < ApplicationMailer

  default from: "ortsleihe@ub.uni-paderborn.de"

  def notify_staff
    @order    = params[:order]
    unique_id = params[:unique_id]
    subject   = ENV["TEST_SERVER_WARNING"] == "true" ? "TEST" : "Bestellung"

    if unique_id.present?
      subject = "#{subject} #{unique_id}"
    end

    mail(to: "bestellung@ublin3.upb.de", subject: subject)
  end

  def confirm_user
    @order = params[:order]
    email  = @order.user.email_address

    if email.present?
      mail(to: email, subject: "Bestellbestätigung für Medium #{@order.signature}")
    end
  end

end
