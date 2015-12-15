class Api::V1::Users::WatchListsController < Api::V1::UsersController
  def create
    call_service(CreateWatchListService,
      description: params[:description],
      name: params[:name],
      user_id: params[:user_id],
      on_success: -> (called_operation) do
        @watch_list = called_operation.result
      end
    )
  end
end
