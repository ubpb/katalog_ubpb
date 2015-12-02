Rails.application.routes.draw do
  get "/:scope/searches",    to: "searches#index", as: :searches
  get "/searches/:id",       to: "searches#show", as: :search # only for compatibility with former catalog
  get "/:scope/records/:id", to: "records#show", as: :record, constraints: { id: /.+/ }

  resource  :session, only: [:create, :destroy, :new]
  resources :closed_stack_orders, only: [:new, :create], path: "cso"

  resource :user, only: [:show] do
    scope module: :users do
      resource  :password, only: [:edit, :update]
      resource  :email_address, only: [:edit, :update]
      resources :former_loans, only: [:index]
      resources :hold_requests, only: [:index, :create, :destroy]
      resources :inter_library_loans, only: [:index]
      resources :transactions, only: [:index]

      resources :loans, only: [:index] do
        put :update, on: :member, action: :renew, as: :renew
        put :update, on: :collection, action: :renew_all, as: :renew_all
      end

      resources :calendars, only: [:index]

      resources :watch_lists do
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

      resources :records, only: [:index, :show], path: ":scope/records" do
        scope module: "records" do
          resources :items, only: [:index]
        end
      end

      resources :users, only: [] do
        scope module: "users" do
          resources :notes, only: [:create, :update, :destroy]
          resources :watch_lists do
            scope module: "watch_lists" do
              resources :entries, only: [:create, :destroy]
            end
          end
        end
      end
    end
  end
end
