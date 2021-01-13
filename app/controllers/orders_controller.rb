require "wicked_pdf"
require "barby"
require "barby/barcode/code_128"
require "barby/outputter/svg_outputter"

class OrdersController < ApplicationController
  include UrlUtils

  before_action :authenticate!, except: :index
  before_action { add_breadcrumb name: "orders#new" }

  def new
    @order = Order.new
    @order.signature = params[:signature]
    @order.title = params[:title]
    @order.loan_status = params[:loan_status]
    @order.is_mono_order = true
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user
    @order.created_at = Time.zone.now

    # Create a unique ID to identify the order in mail to print jobs
    random_code = SecureRandom.hex(5)
    secure_signature = @order.signature.gsub(/\/|\(|\)/, "_")
    timetamp = l(@order.created_at, format: "%Y-%m-%d_%H-%M-%S")
    unique_id = "#{timetamp}_#{@order.user.ilsusername}_#{secure_signature}_#{random_code}"

    # Create barcode
    barcode_svg = Barby::Code128.new(@order.user.ilsusername).to_svg(margin: 0, xdim: 3)
    @order.barcode = "data:image/svg+xml;utf8,#{barcode_svg.gsub(/\n/, '')}"

    # Render attchment
    attachment_html = render_to_string(template: "order_mailer/attachment", layout: "mailer")
    attachment_pdf  = WickedPdf.new.pdf_from_string(attachment_html)

    # Create Mails
    notify_staff_mail = OrderMailer.with(order: @order, unique_id: unique_id).notify_staff
    notify_staff_mail.attachments["#{unique_id}.pdf"] = attachment_pdf
    confirm_user_mail = OrderMailer.with(order: @order).confirm_user

    if @order.valid?
      notify_staff_mail.deliver_now
      confirm_user_mail.deliver_now
      flash[:success] = "Vielen Dank für Ihre Bestellung. Sie erhalten eine gesonderte Bereitstellungsnachricht via E-Mail wenn Sie das Medium abholen können."
      redirect_to(orders_path)
    else
      render :new
    end
  end

private

  def order_params
    params.require(:order).permit(:signature, :is_mono_order, :year, :volume, :title, :loan_status)
  end

end
