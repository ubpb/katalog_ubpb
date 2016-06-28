class PasswordsController < ApplicationController

  before_action :verify_password_reset_token
  before_action :reset_session # make sure we have no open login in the session

  def edit
    @password_form = PasswordForm.new
  end

  def update
    @password_form = PasswordForm.new(password_params)

    if @password_form.valid? && ils_adapter.update_user(@user.ilsuserid, password: @password_form.password) && @user.clear_password_reset_token!
      flash[:success] = t(".flash_success")
      redirect_to(new_session_path)
    else
      render :edit
    end
  end

private

  def verify_password_reset_token
    @token = params[:token]
    @user = User.find_by(password_reset_token: @token)

    if @user.blank?
      flash[:error] = t("passwords.flash_no_user_error")
      return redirect_to(new_session_path)
    elsif @user.password_reset_token_created_at + 24.hours <= Time.zone.now
      flash[:error] = t("passwords.flash_token_to_old_error")
      return redirect_to(new_session_path)
    end
  end

  def password_params
    params.require(:password_form).permit(:password, :password_confirmation)
  end

  def ils_adapter
    current_scope.ils_adapter.instance
  end

end
