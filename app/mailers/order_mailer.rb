class OrderMailer < ApplicationMailer

  default from: "ortsleihe@ub.uni-paderborn.de"

  def notify_staff
    @order = params[:order]

    # Subject must be unique for external "mail to print" processing
    random_code = SecureRandom.hex(5)
    secure_signature = @order.signature.gsub(/\//, "_")
    subject_timestamp = l(@order.created_at, format: "%Y-%m-%d_%H-%M-%S")
    subject_timestamp = "#{subject_timestamp}_#{secure_signature}_#{random_code}"

    subject = ENV["TEST_SERVER_WARNING"] == "true" ? "TEST" : "Bestellung"
    subject = "#{subject} #{subject_timestamp}"

    if ENV["TEST_SERVER_WARNING"] == "true"
      mail(to: "r.sprotte@ub.uni-paderborn.de", subject: subject)
    else
      mail(to: "bestellung@ublin3.upb.de", subject: subject)
    end
  end

  def confirm_user
    @order = params[:order]
    email  = @order.user.email_address

    if email.present?
      mail(to: email, subject: "Bestellbestätigung für Medium #{@order.signature}")
    end
  end

end
