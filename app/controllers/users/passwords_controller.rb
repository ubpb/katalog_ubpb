class Users::PasswordsController < UsersController
  def edit
    @update_user_password = Skala::UpdateUserPasswordService.new({
      ils_adapter: Skala.config.ils_adapter.instance,
      user_id: current_user.username
    })
  end

  def update
    @update_user_password = Skala::UpdateUserPasswordService.new({
      ils_adapter: Skala.config.ils_adapter.instance,
      user_id: current_user.username
    }.merge(update_user_password_params))

    if @update_user_password.invalid?
      render action: :edit
    else
      @update_user_password.call!.tap do |called_operation|
        if called_operation.succeeded?
          flash[:success] = t(".success")
          redirect_to user_path
        else
          raise Servizio::OperationFailedError
        end
      end
    end
  end

  #
  private
  #
  def update_user_password_params
    params.require(:update_user_password).permit(
      :current_password,
      :new_password,
      :new_password_confirmation
    )
  end
end
