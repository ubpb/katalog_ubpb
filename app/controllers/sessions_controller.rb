class SessionsController < ApplicationController

  before_filter :capture_return_path

  def create
    return redirect!(cancel: true) if params[:cancel].present?

    @authenticate_user = AuthenticateUserService.new(
      authenticate_user_params.merge(
        adapter: KatalogUbpb.config.ils_adapter.instance
      )
    )

    if @authenticate_user.valid?
      if @authenticate_user.call!.succeeded?
        if @authenticate_user.result == true
          user = GetUserService.call(
            get_user_params.merge(
              adapter: KatalogUbpb.config.ils_adapter.instance
            )
          )

          # Login the user
          session[:user_id] = user.id

          # Redirect
          redirect!
        else
          flash.now[:error] = t(".failed")
          render action: :new
        end
      else
        flash.now[:error] = t(".error")
        render action: :new
      end
    else
      render action: :new
    end
  end

  def destroy
    reset_session # this is a rails method
    redirect_to root_path
  end

  def new
    @authenticate_user = AuthenticateUserService.new
  end

private

  def authenticate_user_params
    params.require(:authenticate_user).permit(:username, :password)
  end

  def get_user_params
    params.require(:authenticate_user).permit(:username)
  end

  def redirect!(cancel: false)
    return_to   = session.delete(:return_to) || {}
    return_path = return_to["return_path"]
    redirect    = return_to["redirect"]

    if cancel
      return_path ||= root_path
      redirect = true
    end

    if return_path && redirect == true
      redirect_to(return_path)
    else
      flash[:success] = flash_message(return_path)
      redirect_to(user_path)
    end
  end

  def capture_return_path
    return_path = sanitize_return_path(params[:return_to])
    redirect    = params[:redirect].present? && ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(params[:redirect])

    if return_path.present?
      session[:return_to] = {
        return_path: return_path,
        redirect: redirect
      }
    end
  end

  def flash_message(return_path = nil)
    message = t(".success")

    if return_path.present?
      message += " "
      message += t(".return_message", return_path: return_path)
    end

    message.html_safe
  end

end
