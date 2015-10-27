class Api::V1::Users::WatchLists::EntriesController < Api::V1::UsersController
  def create
    user = (current_user_requested? ? current_user : Skala::User.find_by_id(params[:user_id]))
    watch_list = user.try(:watch_lists).try(:find_by_id, params[:watch_list_id])

    if user.nil? || watch_list.nil?
      head :not_found and return
    end

    create_entry = Skala::User::WatchList::CreateEntry.new({
      record: Skala::Record.new(record_params),
      scope: KatalogUbpb.config.find_search_scope(params[:scope][:id]),
      watch_list: watch_list
    })

    if can?(:call, create_entry)
      if create_entry.valid?
        if create_entry.call!.succeeded?
          render "entry", locals: { entry: create_entry.result }
        else
          head create_entry.errors[:http_status].first || :internal_server_error
        end
      else
        head :bad_request
      end
    else
      head :unauthorized
    end
  end

  def destroy
    user = (current_user_requested? ? current_user : Skala::User.find_by_id(params[:user_id]))
    watch_list = user.try(:watch_lists).try(:find_by_id, params[:watch_list_id])
    entry = watch_list.try(:entries).try(:find_by_id, params[:id])

    if user.nil? || watch_list.nil? || entry.nil?
      head :not_found and return
    end

    destroy_entry = Skala::User::WatchList::DeleteEntry.new({
      entry: entry,
      user: user
    })

    if can?(:call, destroy_entry)
      if destroy_entry.valid?
        if destroy_entry.call!.succeeded?
          render json: nil, status: :ok # json: nil is needed for jquery success
        else
          head destroy_entry.errors[:http_status].first || :internal_server_error
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
  def current_user_requested?
    params[:user_id].try(:to_i) == current_user.id
  end

  def record_params
    params.require("record").permit(:id)
  end
end
