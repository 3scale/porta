DeveloperPortal::Engine.routes.draw do

  get '/auth/:system_name/callback' => 'login#create'
  get '/auth/invitations/:invitation_token/:system_name/callback' => 'accounts/invitee_signups#sso_create'

  resource :session, only: :create, controller: 'login'

  # we are using the singular 'signup' so that the liquid templates
  # can keep the system names 'signup/*'
  resource :signup, :controller => 'signup', :only => [:show, :create] do
    collection do
      get :success
    end
  end

  # settings
  get 'privacy' => 'settings#privacy', :as => :settings_privacy
  get 'refunds' => 'settings#refunds', :as => :settings_refunds
  get 'terms'   => 'settings#terms',   :as => :settings_terms

  match 'access_code' => 'access_codes#show', :as => :access_code, :via => [:post, :get]

  namespace :api_docs do
    get 'login' => 'sessions#new', :as => :login
    resource :account_data, :only => [:show]
    resources :services, only: [:show, :index]
  end

  namespace :admin do
    resources :buyer_services, :only => [:index], :controller => 'services', :path => 'services'
    resources :service_contracts, :only => [:new, :create]

    # admin_account
    resource :account, :only => [ :show, :edit, :update ]

    # admin_account_*
    #
    # TODO: include above (not included because the controllers are
    # located under the 'account' folder
    #
    namespace :account do
      resource :payment_details, :only => [:show, :edit, :update], :controller => :payment_details_base do
        member do
          get :hosted_success
        end
      end

      resource :authorize_net, :braintree_blue, :ogone, :adyen12, :stripe, only: [:show, :edit] do
        match 'hosted_success', via: [:get, :post], on: :member
      end

      resources :users, :only => [:index, :edit, :update, :destroy]

      resources :invitations, :only => [:index, :new, :create, :destroy] do
        member do
          put :resend
        end
      end

      resources :account_plans, :only => [:index, :show] do
        collection do
          post :change
        end
      end

      resource :personal_details, :only => [:show, :update]
      resource :password, :only => [:new, :show, :create, :update]
      resources :invoices, :only => [:index, :show]
      resources :plan_changes, only: [:index, :new, :destroy]
    end


    # admin_applications_access_details => /admin/access_details
    # TODO: remove from the 'applications' module to correspond with the URI
    scope as: 'applications', module: 'applications' do
      resource :access_details, only: :show
    end

    # admin_applications...
    resources :applications do
      collection do
        get :choose_service
      end

      resources :keys, :only => [:new, :create, :destroy], module: :applications do
        member do
          put :regenerate
        end
      end

      resource :user_key, :only => [:update], module: 'applications'

      resources :referrer_filters, :only => [:create, :destroy], controller: 'applications/referrer_filters'

      resources :alerts, module: 'applications' do
        collection do
          delete :purge
          put :all_read
        end
        member do
          put :read
        end
      end
    end

    # admin_services_...
    resources :services, :only => [] do
      get 'plans_widget' => 'plans_widget#index', :as => :plans_widget
    end

    # admin_contract_service_plan_path
    resources :contracts, :only => [:update] do
      resources :service_plans, :only => [:index], :module => 'contracts'
    end

    # admin_messages_....
    namespace :messages do
      root :to => redirect('/admin/messages/received')
      get 'new' => 'outbox#new', :as => :new
      resources :inbox, :only => [:index, :show, :destroy, :create], :path => 'received'
      resources :outbox, :except => [:edit, :update], :path => 'sent'
      resources :trash, :only => ['index', 'show', 'destroy'] do
        collection do
          delete 'empty', :path => '' # this is a delete on the index
        end
      end
    end
  end

  namespace :buyer do
    resource :contract, :only => :show
    resource :account_contract, :only => [:update]
    resources :stats, :only => :index do

      member do
        get :methods, action: :methods_list
        get :metrics, action: :metrics_list
      end

    end
    get 'stats/data/usage/:metric_id' => 'stats#index_data', :as => :stats_index_data
  end

  # /swagger/spec
  namespace :swagger do
    resources :spec, only: [:index, :show]
  end

  # legacy API route
  post 'buyer/plans/:id/change.:format' => 'admin/account/account_plans#change'

  get 'login'     => 'login#new',    :as => :login
  get 'logout'     => 'login#destroy',    :as => :logout
  get 'logged_out' => 'login#logged_out', :as => :logged_out
  get 'session/create' => 'login#create', :as => :create_session

  get '/admin' => 'dashboards#show', :as => :admin_dashboard
  get 'activate/:activation_code' => 'activations#create', :as => :activate
  resource :invitee_signup, path: "signup/:invitation_token", only: [:show, :create], module: :accounts

  get '/search(.:format)' => 'search#index', :as => :search

  root :to => 'cms/new_content#show'
  get '*path' => 'cms/new_content#show'
end
