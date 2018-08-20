Rails.application.routes.draw do
  get "/:scope/searches",    to: "searches#index", as: :searches
  get "/:scope/records/:id", to: "records#show", as: :record, constraints: { id: /.+/ }

  post "/login",  to: "sessions#create", as: :session
  get  "/login",  to: "sessions#new", as: :new_session
  get  "/logout", to: "sessions#destroy", as: :logout

  resources :closed_stack_orders, only: [:new, :create], path: "cso"

  resource :password_reset, only: [:new, :create], path: "password/reset"
  get "/password/:token", to: "passwords#edit", as: :edit_password
  put "/password/:token", to: "passwords#update", as: :password

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
  get "/records/:id",                     to: "compatibility/records#show", constraints: { id: /.+/ }
  get "/searches",                        to: "compatibility/searches#index"
  get "/searches/:id",                    to: "compatibility/searches#show"
  get "/searches/:search_id/records/:id", to: "compatibility/records#show", constraints: { id: /.+/ }

  #
  # Some kickers
  #
  get "/go/signature", to: redirect("http://www.ub.uni-paderborn.de/nutzen-und-leihen/medienaufstellung-nach-systemstellen/"), as: :go_signature
  get "/go/journal-signature", to: redirect("http://www.ub.uni-paderborn.de/nutzen-und-leihen/medienaufstellung-nach-fachkennziffern/"), as: :go_journal_signature
  get "/go/ill", to: redirect("https://www.digibib.net/jumpto?D_SERVICE=TEMPLATE&D_SUBSERVICE=ILL_ACCOUNT&LOCATION=466"), as: :go_ill

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
          # maybe constraints: { id: /.+/ } is needed
          get "records/*record_id/items", to: "records/items#index", as: "record_items" # position this before the records/*id below
          get "records/*id",              to: "records#show",        as: "records"

          resources :searches, only: [:index]
        end
      end

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

      # /api/v1/cover-images/:id
      get "cover-images/:id", to: "cover_images#show", as: "cover_image"

      # /api/v1/recommendations?<open url params>
      get "recommendations", to: "recommendations#show", as: :recommendations
    end
  end
end
