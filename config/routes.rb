Rails.application.routes.draw do
  resources :closed_stack_orders, only: [:new, :create], path: 'cso'
  resource  :homepage, only: [:show]
  resources :records, only: [:show]
  resources :searches, only: [:index]

  resource :session, only: [:create, :destroy, :new] do
    resource :local, only: [:update]
  end

  resources :tickets, :only => [:new, :create]
  resources :thumbnails, :only => :show

  resource :user, only: [:show, :update] do
    scope module: "users" do
      resource  :email_address, only: [:edit, :update]
      resources :fees, only: [:index]
      resources :former_loans, only: [:index]
      resources :hold_requests, only: [:index, :create, :destroy]
      resources :inter_library_loans, only: [:index]

      resources :loans, only: [:index] do
        put :update, on: :member, action: :renew, as: :renew
        put :update, on: :collection, action: :renew_all, as: :renew_all
      end

      resources :calendars, only: [:index]

      resource :password, only: [:edit, :update]
      resources :watch_lists do
        delete :index, on: :collection, action: :destroy

        scope module: "watch_lists" do
          resources :entries, only: [:create, :destroy] do
            delete :index, on: :collection, action: :destroy
          end
        end
      end
    end
  end

  get '/semapp/info' => 'semapp#info', as: :semapp_info
  get '/realtime_availability' => 'realtime_availability#check_availability'


  get "/go/signature", to: redirect("http://www.ub.uni-paderborn.de/lernen_und_arbeiten/bestaende/medienaufstellung-systemstelle.shtml"), as: :go_signature


  root :to => "homepage#show"

  #
  # api
  #
  namespace :api do
    namespace :v1 do
      get 'user/calendar' => 'calendar#show'
      resources :records, only: [:index, :show], :constraints => { :id => /.*/ } do
        scope module: 'records' do
          resources :items, only: [:index]
        end
      end

      resources :users, only: [:show, :update] do
        scope module: "users" do
          resources :notes, only: [:create, :update, :destroy]
          resource :password, only: [:update]

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
