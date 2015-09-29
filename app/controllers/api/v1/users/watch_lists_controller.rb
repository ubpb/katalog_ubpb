class Api::V1::Users::WatchListsController < Api::V1::UsersController
  def create
    user = (current_user_requested? ? current_user : Skala::User.find_by_id(params[:user_id]))

    if user.nil?
      head :not_found and return
    end

    create_watch_list = Skala::User::CreateWatchList.new({
      description: watch_list_params[:description],
      name: watch_list_params[:name],
      user: user
    })

    if can?(:call, operation = create_watch_list)
      if operation.valid?
        if operation.call!.succeeded?
          render "watch_list", locals: { watch_list: operation.result }
        else
          head operation.errors[:http_status].first || :internal_server_error
        end
      else
        head :bad_request
      end
    else
      head :unauthorized
    end
  end

  #
  private
  #
  def watch_list_params
    params.require(:watch_list).permit(:description, :name)
  end
end
