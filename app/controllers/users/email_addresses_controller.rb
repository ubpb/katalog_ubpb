class Users::EmailAddressesController < UsersController
  def edit
    @update_user_email_address = Skala::UpdateUserEmailAddressService.new({
      current_email_address: current_user.email_address,
      ils_adapter: KatalogUbpb.config.ils_adapter.instance,
      user_id: current_user.username
    })
  end

  def update
    @update_user_email_address = Skala::UpdateUserEmailAddressService.new({
      ils_adapter: KatalogUbpb.config.ils_adapter.instance,
      user_id: current_user.username
    }.merge(update_user_email_address_params))

    if @update_user_email_address.invalid?
      render action: :edit
    else
      @update_user_email_address.call!.tap do |called_operation|
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
  def update_user_email_address_params
    params.require(:update_user_email_address).permit(
      :new_email_address
    )
  end
end
