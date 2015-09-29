class Users::WatchLists::EntriesController < UsersController
  def create
    @entry = current_user.watch_lists.find_by_id(params[:watch_list_id]).entries.create entry_params
  end

  def destroy
    watch_list = Skala::User::WatchList.find_by_id(params[:watch_list_id])

    (params[:ids] || [params[:id]]).compact.each do |_entry_id|
      delete_entry = Skala::User::WatchList::DeleteEntry.new({
        entry: watch_list.entries.find_by_id(_entry_id) || watch_list.entries.find_by_record_id(_entry_id),
        user: current_user
      })

      if delete_entry.valid?
        if can?(:call, delete_entry)
          delete_entry.call
        else
          flash[:error] = t(".not_authorized_to_destroy")
        end
      end
    end

    redirect_to user_watch_list_path(params[:watch_list_id])
  end

  #
  private
  #
  def entry_params
    params.require(:entry).permit(:record_id, :scope_id)
  end
end
