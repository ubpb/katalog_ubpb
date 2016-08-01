class Users::EmailAddressesController < UsersController

  before_action { add_breadcrumb name: "users.email_addresses#edit" }

  def edit
    @update_user_email_address = UpdateUserEmailAddressService.new(
      adapter: KatalogUbpb.config.ils_adapter.instance,
      user: current_user
    )

    return raise NotAuthorizedError if cannot?(:call, @update_user_email_address)
  end

  def update
    @update_user_email_address = UpdateUserEmailAddressService.new(
      update_user_email_address_params.merge(
        adapter: KatalogUbpb.config.ils_adapter.instance,
        user: current_user
      )
    )

    return raise NotAuthorizedError if cannot?(:call, @update_user_email_address)

    if @update_user_email_address.invalid?
      render action: :edit
    else
      if @update_user_email_address.call!.succeeded?
        flash[:success] = t(".success")
      else
        flash[:error] = t(".update_user_email_address_failed")
      end

      redirect_to user_path
    end
  end

  #
  private
  #
  def update_user_email_address_params
    params.require(:update_user_email_address).permit(
      :new_email_address
    )
  end
end
