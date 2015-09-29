class Users::WatchListsController < UsersController
  before_action -> do
    add_breadcrumb name: "users#show", url: user_path
    add_breadcrumb
  end, only: [:index]

  before_action -> do
    add_breadcrumb name: "users#show", url: user_path
    add_breadcrumb name: "users.watch_lists#index", url: user_watch_lists_path
    add_breadcrumb
  end, only: [:new]

  def create
    @create_watch_list = Skala::User::CreateWatchList.new(
      create_watch_list_params.merge({
        user: current_user
      })
    )

    if @create_watch_list.valid?
      if can?(:call, @create_watch_list)
        @create_watch_list.call.try do |_called_operation|
          unless _called_operation.succeeded?
            flash[:error] = t(".error")
          end
        end
      end

      redirect_to user_watch_lists_path
    else
      render action: :new
    end
  end

  def destroy
    (destroy_params[:ids] || [destroy_params[:id]]).compact.each do |_watch_list_id|
      delete_watch_list = Skala::User::DeleteWatchListService.new({
        user: current_user,
        watch_list: Skala::User::WatchList.find_by_id(_watch_list_id)
      })

      if can?(:call, delete_watch_list)
        delete_watch_list.call
      else
        flash[:error] = t(".not_authorized_to_destroy")
      end
    end

    redirect_to user_watch_lists_path
  end

  def index
    @watch_lists = current_user.watch_lists.decorate
  end

  def new
    @create_watch_list = Skala::User::CreateWatchList.new
  end

  def update
    call_operation (@watch_list_edit = Skala::WatchLists::Edit.new({
      new_description: params[:watch_list_edit][:new_description],
      new_label: params[:watch_list_edit][:new_label],
      watch_list: @watch_list
    })),
    on_success: -> (op) do
      redirect_to action: :show
    end,
    on_invalid: -> (op) do
      render action: :edit, layout: "user"
    end
  end

  def show
    if watch_list = current_user.watch_lists.find_by_id(params[:id])
      @watch_list = watch_list.decorate
      @records = @watch_list.entries
      .inject({}) do |_memo, _entry|
        (_memo[_entry.scope_id] ||= []).push(_entry.record_id) and _memo
      end
      .inject([]) do |_memo, (_scope_id, _record_ids)|
        w = {
          "from" => 0,
          "size" => _record_ids.length,
          "query" => {
            "bool" => {
              "must" => {
                "query_string" => {
                  "default_operator" => "OR",
                  "fields" => ["identifier"],
                  "query" => _record_ids.join(" ")

                }
              }
            }
          }
        }

        scope = Skala::Scope.find(_scope_id)
        op = Skala::SearchRecords.new({
          facets: {},
          request: request,
          search_engine_adapter: scope.search_engine_adapter,
          search_request: w
        })

        _memo.concat(
          op.call!.result[1].map do |_hit|
            _hit.scope = scope
            _hit
          end
        )
      end
      .map! do |_record|
        _record.decorate
      end

      @notes = current_user.try(:notes)
      @watch_lists = current_user.watch_lists.includes(:entries).select do |_watch_list|
        # we remove the current watch list, else we had to handle the case of "inline" removing an entry
        _watch_list != @watch_list
      end

      # we cannot use before_action here because we have to fetch the watch list first
      add_breadcrumb name: "users#show", url: user_path
      add_breadcrumb name: "users.watch_lists#index", url: user_watch_lists_path
      add_breadcrumb name: @watch_list.name
    else
      flash[:error] = t(".watch_list_not_found")
      redirect_to user_watch_lists_path
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
end
