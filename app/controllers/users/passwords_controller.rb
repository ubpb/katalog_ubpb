class Users::PasswordsController < UsersController

  before_action { add_breadcrumb name: "users.passwords#edit" }

  def edit
    @update_user_password = UpdateUserPasswordService.new(
      adapter: KatalogUbpb.config.ils_adapter.instance,
      user: current_user
    )

    return raise NotAuthorizedError if cannot?(:call, @update_user_password)
  end

  def update
    @update_user_password = UpdateUserPasswordService.new(
      update_user_password_params.merge(
        adapter: KatalogUbpb.config.ils_adapter.instance,
        user: current_user
      )
    )

    return raise NotAuthorizedError if cannot?(:call, @update_user_password)

    if @update_user_password.invalid?
      render action: :edit
    else
      if @update_user_password.call!.succeeded?
        flash[:success] = t(".success")
      else
        flash[:error] = t(".update_user_password_failed")
      end

      redirect_to user_path
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
