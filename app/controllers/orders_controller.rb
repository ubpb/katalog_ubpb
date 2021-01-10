class OrdersController < ApplicationController
  include UrlUtils

  before_action :authenticate!, except: :index
  before_action { add_breadcrumb name: "orders#new" }

  def new
    @order = Order.new
    @order.signature = params[:signature]
    @order.is_mono_order = true
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user

    notify_staff_mail = OrderMailer.with(order: @order).notify_staff
    confirm_user_mail = OrderMailer.with(order: @order).confirm_user

    notify_staff_mail_content = notify_staff_mail.body.raw_source

    if @order.valid?
      if send_to_printer(notify_staff_mail_content, "Brother_HL_3152CDW_series_XXX")
        notify_staff_mail.deliver_now
        confirm_user_mail.deliver_now

        flash[:success] = "Vielen Dank für Ihre Bestellung. Sie erhalten eine gesonderte Bereitstellungsnachricht via E-Mail wenn Sie das Medium abholen können."
      else
        flash[:error] = "Fehler: Bestellung konnte nicht abgeschickt werden. Bitte versuchen Sie es erneut."
      end

      redirect_to(orders_path)
    else
      render :new
    end
  end

private

  def order_params
    params.require(:order).permit(:signature, :is_mono_order, :year, :volume)
  end

  def send_to_printer(content, printer_name)
    # file = Tempfile.new('order_print')
    # file.write(content)
    # file.close

    # `lpr -P #{printer_name} #{file.path} 2>&1`
    # $?.success?
    true
  ensure
   #file.unlink
  end

end
