class Users::WatchListsController < UsersController

  before_action { add_breadcrumb name: "users.watch_lists#index", url: user_watch_lists_path }

  def index
    @get_user_watch_lists = GetUserWatchListsService.new(include: :watch_list_entries, user: current_user)

    if cannot?(:call, @get_user_watch_lists)
      return redirect_to user_path
    else
      @watch_lists = @get_user_watch_lists.call!.result
    end
  end

  def new
    create
  end

  def create
    @create_watch_list = CreateWatchListService.new(
      description: params[:create_watch_list].try(:[], :description),
      name: params[:create_watch_list].try(:[], :name),
      user: current_user
    )

    if cannot?(:call, @create_watch_list)
      flash[:error] = t(".not_allowed_to_create_watch_list")
      return redirect_to user_watch_lists_path
    end

    unless params[:commit]
      render action: :new
    else
      if @create_watch_list.invalid?
        render action: :new
      else
        @create_watch_list.call!
        flash[:error] = t(".watch_list_could_not_be_created") if @create_watch_list.failed?
        redirect_to user_watch_lists_path
      end
    end
  end

  def edit
    update
  end

  def update
    if @watch_list = GetWatchListService.call(id: params[:id])
      @update_watch_list = UpdateWatchListService.new(
        new_description: params[:update_watch_list].try(:[], :new_description),
        new_name: params[:update_watch_list].try(:[], :new_name),
        watch_list: @watch_list
      )

      if cannot?(:call, @update_watch_list)
        flash[:error] = t(".not_allowed_to_update_watch_list")
        return redirect_to user_watch_lists_path
      end

      unless params[:commit]
        render action: :edit
      else
        if @update_watch_list.invalid?
          render action: :edit
        else
          @update_watch_list.call!
          flash[:error] = t(".watch_list_could_not_be_updated") if @update_watch_list.failed?
          redirect_to user_watch_list_path(@watch_list)
        end
      end
    else
      flash[:error] = t(".watch_list_not_found")
      return redirect_to user_watch_lists_path
    end
  end

  def show
    get_watch_list = GetWatchListService.new(id: params[:id])

    if can?(:call, get_watch_list)
      if (@watch_list = get_watch_list.call!.result).present?
        get_watch_list_watch_list_entries = GetWatchListWatchListEntriesService.new(
          scopes: KatalogUbpb.config.scopes,
          watch_list: @watch_list
        )

        if can?(:call, get_watch_list_watch_list_entries)
          @watch_list_entries = get_watch_list_watch_list_entries.call!.result
          @watch_list_entries = reorder_entries(@watch_list_entries, params[:order_by])
        else
          flash[:error] = t(".not_allowed_to_get_watch_list_entries")
          return redirect_to user_watch_lists_path
        end
      else
        flash[:error] = t(".watch_list_not_found")
        return redirect_to user_watch_lists_path
      end
    else
      flash[:error] = t(".not_allowed_to_show_watch_list")
      return redirect_to user_watch_lists_path
    end

    @notes = GetUserNotesService.call(user: current_user)
    @watch_lists = GetUserWatchListsService.call(include: :watch_list_entries, user: current_user)

    # we cannot use before_action here because we have to fetch the watch list first
    add_breadcrumb name: @watch_list.name
  end

  def destroy
    delete_watch_list = DeleteWatchListService.new(id: params[:id])

    if can?(:call, delete_watch_list)
      delete_watch_list.call!
      flash[:error] = t(".watch_list_could_not_be_deleted") if delete_watch_list.failed?
      redirect_to user_watch_lists_path
    else
      flash[:error] = t(".not_allowed_to_delete_watch_list")
      return redirect_to user_watch_lists_path
    end
  end

  #
  private
  #
  def create_watch_list_params
    params.require(:create_watch_list).permit(:description, :name)
  end

  def destroy_params
    params.tap do |_params|
      _params[:ids] = _params[:ids].keys if _params[:ids].is_a?(Hash)
    end
  end

  def reorder_entries(entries, order_by)
    order_by = [
      "signature", "created_at"
    ].find{|o| o == order_by.to_s}

    case order_by
    when "signature"  then entries_by_signature(entries)
    when "created_at" then entries_by_created_at(entries)
    else
      entries_by_created_at(entries)
    end
  end

  def entries_by_signature(entries)
    entries.sort do |a, b|
      a_signature = a.record.try(:signature)
      b_signature = b.record.try(:signature)
      if a_signature && b_signature
        a_signature <=> b_signature
      else
        0
      end
    end
  end

  def entries_by_created_at(entries)
    entries.sort do |a, b|
      a.created_at <=> b.created_at
    end
  end
end

