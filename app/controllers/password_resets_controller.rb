class PasswordResetsController < ApplicationController

  def new
    @password_reset_form = PasswordResetForm.new({ ilsid: params[:ilsid] }, ils_adapter: ils_adapter)
  end

  def create
    @password_reset_form = PasswordResetForm.new(password_reset_params, ils_adapter: ils_adapter)

    if @password_reset_form.valid?
      user  = @password_reset_form.user
      token = user.recreate_password_reset_token!

      PasswordResetsMailer.notify_user(user).deliver_later

      flash[:success] = "Wir haben Ihnen soeben auf die E-Mail Adresse des Bibliothekskontos mit der Nummer '#{user.ilsuserid}' Informationen gesendet, mit denen Sie Ihr Passwort zurücksetzen können."
      redirect_to(new_session_path)
    else
      render :new
    end
  end

private

  def password_reset_params
    params.require(:password_reset_form).permit(:ilsid)
  end

  def ils_adapter
    current_scope.ils_adapter.instance
  end

end
