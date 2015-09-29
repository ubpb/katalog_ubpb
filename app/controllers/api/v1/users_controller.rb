class Api::V1::UsersController < Api::V1::ApplicationController
  before_action :authenticate!

  def show
    if (user = User.find_by_id(params[:id])).present?
      if (get_user = Skala::GetUserService.new(username: user.username)).valid?
        if can? :call, get_user
          get_user.call.try do |_called_operation|
            @user = _called_operation.result
          end
        else
          head :forbidden
        end
      else
        head :bad_request
      end
    else
      head :not_found
    end
  end
end
