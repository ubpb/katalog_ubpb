class Api::V1::Users::WatchLists::WatchListEntriesController < Api::V1::UsersController
  def create
    call_service(CreateWatchListEntryService,
      record_id: params[:record_id],
      scope_id: params[:scope_id],
      watch_list_id: params[:watch_list_id],
      on_success: -> (called_operation) do
        @watch_list_entry = called_operation.result
      end
    )
  end

  def destroy
    call_service(DeleteWatchListEntryService,
      id: params[:id]
    )
  end
end
