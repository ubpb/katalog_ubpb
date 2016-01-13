Rails.application.routes.draw do
  get "/:scope/searches",    to: "searches#index", as: :searches
  get "/:scope/records/:id", to: "records#show", as: :record, constraints: { id: /.+/ }

  post "/login",  to: "sessions#create", as: :session
  get  "/login",  to: "sessions#new", as: :new_session
  get  "/logout", to: "sessions#destroy", as: :logout

  resources :closed_stack_orders, only: [:new, :create], path: "cso"

  resource :user, only: [:show] do
    scope module: :users do
      resource  :password, only: [:edit, :update]
      resource  :email_address, only: [:edit, :update], path: "email"
      resources :former_loans, only: [:index], path: "loans/history"
      resources :hold_requests, only: [:index, :create, :destroy], path: "hold-requests"
      resources :inter_library_loans, only: [:index], path: "ill"
      resources :transactions, only: [:index]

      resources :loans, only: [:index] do
        put :update, on: :member, action: :renew, as: :renew
        put :update, on: :collection, action: :renew_all, as: :renew_all
      end

      resources :calendars, only: [:index]

      resources :watch_lists, path: "watch-lists" do
        delete :index, on: :collection, action: :destroy

        scope module: :watch_lists do
          resources :entries, only: [:create, :destroy] do
            delete :index, on: :collection, action: :destroy
          end
        end
      end
    end
  end

  #
  # Compatibility with catalog version 1.x
  #
  get "/searches/:id/records/:record_id", to: "v1_searches#record", as: "", constraints: { id: /.+/ }
  get "/searches/:id",                    to: "v1_searches#search", as: ""
  get "/records/:id",                     to: "v1_searches#record", as: "", constraints: { id: /.+/ }
  get "/searches",     to: redirect("/"), as: ""
  get "/records",      to: redirect("/"), as: ""

  #
  # Some kickers
  #
  get "/go/signature", to: redirect("http://www.ub.uni-paderborn.de/lernen_und_arbeiten/bestaende/medienaufstellung-systemstelle.shtml"), as: :go_signature

  #
  # Root path
  #
  root to: "homepage#show"

  #
  # API
  #
  namespace :api do
    namespace :v1 do
      get "user/calendar" => "calendar#show"

      resources :scopes, only: [:index] do
        scope module: "scopes" do
          resources :records, only: [:show] do
            scope module: "records" do
              resources :items, only: [:index]
            end
          end

          resources :searches, only: [:index]
        end
      end

      #resources :searches, only: [:index], path: ":scope_id/searches"

      #resources :records, only: [:index, :show], path: ":scope_id/records" do
      #  scope module: "records" do
      #    resources :items, only: [:index]
      #  end
      #end

      resources :users, only: [:show] do
        scope module: "users" do
          resources :notes, only: [:index]
          resources :watch_lists, only: [:create, :index]
        end
      end

      # /api/v1/notes/:id
      resources :notes, only: [:create, :destroy, :update]

      # /api/v1/watch_lists/:id
      resources :watch_lists, controller: "/api/v1/users/watch_lists", only: [:destroy, :update] do
        resources :watch_list_entries, controller: "/api/v1/users/watch_lists/watch_list_entries", only: [:create, :index]
      end

      # /api/v1/watch_list_entries/:id
      resources :watch_list_entries, controller: "/api/v1/users/watch_lists/watch_list_entries", only: [:destroy]
    end
  end
end
