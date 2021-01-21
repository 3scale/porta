# frozen_string_literal: true

require 'routing_constraints'
require 'prometheus_exporter_port'

class CdnAssets
  def initialize
    @environment = Sprockets::Environment.new
    @environment.append_path 'cdn'
  end

  def call(env)
    @environment.call(env)
  end
end

# rubocop:disable Metrics/BlockLength

Rails.application.routes.draw do

  constraints PortConstraint.new(PrometheusExporterPort.call) do
    require 'sidekiq/prometheus/exporter'
    require 'yabeda/prometheus/mmap'

    mount Sidekiq::Prometheus::Exporter, at: '/metrics'
    mount Yabeda::Prometheus::Exporter, at: '/yabeda-metrics'
  end

  mount CdnAssets.new => '/_cdn_assets_' unless Rails.configuration.three_scale.assets_cdn_host

  resource :openid

  if ThreeScale::Core.url == System::Application.config.three_scale.core.fake_server
    internal = proc do |env|
      [
        200,
        { 'Content-Type' => 'application/json', 'Content-Length' => 2},
        ['{}']
      ]
    end

    constraints DomainConstraint.new(URI(ThreeScale::Core.url).host) do
      mount internal, at: 'internal'
    end
  elsif System::Application.config.three_scale.core.fake_server
    warn <<-WARNING
[config/routes.rb] You need more than 1 unicorn worker to run fake Core server
without fake Core server your after commit callbacks will crash and you might get unexpected failures
    WARNING
  end

  constraints BuyerDomainConstraint do
    # Just for a better user experience,
    # unless should show the message:
    #     "is not accessible on domain provider.3scale.net"
    get '/p/admin/dashboard', to: redirect('/admin')
  end

  #
  #   Master
  #

  constraints MasterOrProviderDomainConstraint do
    root :to => redirect('/p/admin')
    get '/admin', to: redirect('/p/admin')

    namespace :master, module: 'master' do
      namespace :events, :module => 'events', :defaults => { :format => 'xml' } do
        resource :import, :only => :create
      end
    end
  end

  constraints MasterDomainConstraint do
    get "status" => "application#status"
    constraints LoggedInConstraint do
      mount ::Sidekiq::Web, at: 'sidekiq'
      mount ::System::Deploy, at: 'deploy'
    end

    namespace :partners do
      resources :providers, defaults: {format: 'json'} do
        resources :users, only: [:create, :destroy, :index, :show]
      end
      resource :sessions do
        member do
          get "openid"
        end
      end
    end

    namespace :master, module: 'master' do

      namespace :devportal do
        get '/auth/:system_name/callback/' => 'auth#show', constraints: ParameterConstraint.new(:domain)
        get '/auth/:system_name/callback/' => 'auth#show_self', constraints: ParameterConstraint.new(:self_domain)
        get '/auth/invitations/:invitation_token/:system_name/callback' => 'auth#show'
        get '/auth/invitations/auth0/:system_name/callback' => 'auth#show'
      end

      namespace :api, defaults: {format: 'json'} do
        # /master/api/provider
        resources :providers, except: :index do
          member do
            post :change_partner
          end
          resources :services, only: [:destroy]
        end

        namespace :proxy do
          resources :configs, path: 'configs/:environment', only: [:index]
        end

        scope module: 'finance' do
          resources :providers, :only => [] do
            resources :accounts, :only => [], module: 'accounts' do
              resources :billing_jobs, only: [:create]
            end

            resources :billing_jobs, only: [:create]
          end
        end
      end

      resources :providers, module: 'providers', only: [] do
        resource :plan, only: [ :update, :edit ]
        resources :switches, only: [ :update, :destroy ]
      end
    end
  end

  resource :raise, :only => [:show]

  get '/stylesheets/theme.css' => 'cms/stylesheets#show', :as => :cms_stylesheet, :name => 'theme'
  get '/stylesheets/provider_customized.css' => 'cms/stylesheets#show', :as => :cms_stylesheet_provider, :name => 'provider_customized'

  if ThreeScale.config.redhat_customer_portal.enabled
    constraints MasterDomainConstraint do
      get "/auth/#{RedhatCustomerPortalSupport::RH_CUSTOMER_PORTAL_SYSTEM_NAME}/callback" => 'master/redhat/auth#show'
    end

    namespace :provider, :path => 'p', constraints: ProviderDomainConstraint do
      namespace :admin do
        get "/auth/#{RedhatCustomerPortalSupport::RH_CUSTOMER_PORTAL_SYSTEM_NAME}/callback" => 'redhat/auth#show'
      end
    end
  end

  if ThreeScale.config.service_discovery.enabled && ThreeScale.config.service_discovery.authentication_method == 'oauth'
    constraints MasterDomainConstraint do
      get "/auth/#{ServiceDiscovery::AuthenticationProviderSupport::SERVICE_DISCOVERY_SYSTEM_NAME}/callback" => 'master/service_discovery/auth#show'
    end

    namespace :provider, path: 'p', constraints: ProviderDomainConstraint do
      namespace :admin do
        get "/auth/#{ServiceDiscovery::AuthenticationProviderSupport::SERVICE_DISCOVERY_SYSTEM_NAME}/callback" => 'service_discovery/auth#show'
      end
    end
  end

  get '/auth/:system_name/callback' => 'provider/sessions#create', constraints: MasterOrProviderDomainConstraint
  get '/auth/:system_name/bounce' => 'provider/sessions#bounce', constraints: ProviderDomainConstraint, as: :authorization_provider_bounce

  namespace :provider, path: 'p', constraints: ProviderDomainConstraint do
    resource :password, only: %i[new show update destroy] do
      get 'reset'
    end
  end

  namespace :provider, :path => 'p', constraints: MasterOrProviderDomainConstraint do
    get 'activate/:activation_code' => 'activations#create', :as => :activate

    resource :domains, :only => [:show] do
      collection do
        post :recover
      end
    end


    resource :signup, :only => [:show, :create] do
      match '', action: :cors, via: 'OPTIONS'
      match '*path', action: :cors, via: 'OPTIONS'

      collection do
        get :success
        get :test, as: :iframe
      end
    end

    # BEWARE: those 2 routes have to be below /p/signup/success or
    # they would override it.
    resource :invitee_signup, path: "signup/:invitation_token", only: [:show, :create]

    resource :sessions, :only => [:new, :create, :destroy, :show]
    get 'sso' => 'sessions#create'
    get 'login'  => 'sessions#new',     :as => :login
    get 'logout' => 'sessions#destroy', :as => :logout

    get 'admin', to: 'admin#show'

    namespace :admin do
      resources :backend_apis do
        scope module: :backend_apis do
          resources :metrics, :except => [:show] do
            resources :children, :controller => 'metrics', :only => [:new, :create]
          end
          resources :mapping_rules, except: %i[show], defaults: { owner_type: 'BackendApi' }

          namespace :stats do
            get 'usage', to: 'usage#index', as: :usage
          end
        end
      end

      resource :sudo, only: [:new, :show, :create]

      resources :accounts, :only => [:new, :create]
      resources :authentication_providers do
        member do
          patch :publish_or_hide
        end
      end
      resource :dashboard, :only => [:show]

      namespace :dashboard do
        resource :new_accounts, only: [:show]
        resource :potential_upgrades, only: [:show]

        namespace :service, path: 'service/:service_id', as: :service do
          resource :hits, only: [:show]
          resource :integration_errors, only: [:show]
          resource :navigations, only: [:show]
          resource :top_traffic, only: [:show], controller: :top_traffic
        end
      end

      resource :go_live_state, only: [:show, :update]
      resource :account, :only => [:show, :edit, :update]
      resource :api_docs, :only => [:show]
      resource :liquid_docs, :only => [:show]
      resource :webhooks, :only => [ :new, :edit, :create, :update, :show ]

      namespace :registry do
        constraints(id: /((?!\.json\Z)[^\/])+/) do
          resources :policies, except: %i[show delete]
        end
      end

      resources :destroys, :only => [:index]

      namespace :onboarding do
        namespace :wizard do
          root to: 'info#index'

          get 'intro' => 'info#intro'
          get 'explain' => 'info#explain'
          resource :api,         only: [:new, :edit, :update],        controller: :api
          resource :product,     only: [:new, :edit, :update],        controller: :product
          resource :backend_api, only: [:new, :edit, :update],        controller: :backend_api
          resource :connect,     only: [:new, :edit, :update],        controller: :connect
          resource :request,     only: [:new, :edit, :update, :show], controller: :request
          get 'outro' => 'info#outro'
        end
      end

      namespace :messages do
        root to: 'inbox#index'
        resources :inbox, only: [:show, :destroy] do
          member do
            post :reply
          end
        end
        resources :outbox, except: [:edit, :update]
        resources :trash, only: [:index, :show, :destroy] do
          collection do
            delete :empty # delete all
          end
        end

        namespace :bulk do
          resource :trash, only: [:new, :create]
        end
      end

      namespace :api_docs do
        resource :account_data, :only => [:show]
        resources :specs, only: :show
      end

      scope 'applications/:application_id', :as => :application do
        resources :keys, :only => [ :new, :create, :edit, :update, :destroy ] do
          member do
            put :regenerate
          end
        end
        resources :referrer_filters, :only => [:create, :destroy]
      end

      namespace :cms do
        root to: 'templates#index'
        resources :templates, only: [:index] do
          collection do
            get :sidebar
          end

          resources :versions, only: [:index, :show, :destroy] do

            member do
              post :revert
            end
          end
        end

        resources :builtin_sections, controller: 'sections', except: [ :show, :destroy ]

        resources :sections, :except => [:show] do
          resources :changes
        end

        resources :builtin_static_pages, :builtin_pages, :builtin_partials, only: [:edit, :update] do
          member do
            put :publish
          end
        end

        resources :pages, :layouts, :partials, except: [:show, :index] do
          member do
            put :publish
          end
        end

        resources :email_templates, :except => [:show]
        resources :builtin_legal_terms, :except => [ :show, :index ]

        resources :portlets, :except => [:show] do
          collection do
            get :pick
          end
          member do
            put :publish
          end

        end

        resources :switches, :only => [ :index, :update, :destroy ]
        resources :files, :except => [:show]
        resources :redirects, :except => [:show]
        resources :sections, :except => [:show]
        resources :groups, :except => [:show]
        resources :changes do
          collection do
            put :publish_all
          end
          member do
            put :publish
            put :revert
          end

        end
      end

      namespace :user do
        resource :notification_preferences, only: [:show, :update]
        resource :personal_details, only: [:edit, :update]
        resources :access_tokens, only: [:index, :new, :create, :edit, :update, :destroy]
      end

      namespace :account do
        resources :authentication_providers do
          resource :publishing, :controller => 'authentication_provider_publishing', :only => [:create, :destroy]
          get :auth_show, controller: :authentication_provider_flow_testing, on: :member, as: :flow_testing_show
        end
        get '/callback/:system_name', action: :callback, controller: :authentication_provider_flow_testing, as: :flow_testing_callback

        resource :enforce_sso, :controller => 'enforce_sso', :only => [:create, :destroy]
        resources :notifications, :only => [:index, :update]
        resources :users, :only => [:index, :edit, :update, :destroy] do
          resources :access_tokens, only: [:index, :new, :create, :edit, :update, :destroy]
        end

        resource :braintree_blue, only: [:show, :edit, :update, :destroy], module: 'payment_gateways' do
          match 'hosted_success', via: [:get, :post], on: :member
        end
        resource :data_exports, :only => [:new, :create]
        resource :logo, only: %i[edit update destroy]

        resources :invitations, :only => [:index, :new, :create, :destroy] do
          member do
            put :resend
          end
        end

        resource :personal_details, only: [] do
          match '/', via: :any, to: redirect { System::UrlHelpers.system_url_helpers.edit_provider_admin_user_personal_details_path }
          get 'edit', action: 'edit', on: :member, to: redirect { System::UrlHelpers.system_url_helpers.edit_provider_admin_user_personal_details_path }
        end

        resource :change_plan, :only => [:show, :update] do
          member do
            get :widget
          end
        end

        resources :invoices, :only => [:show, :index]
      end

      namespace :service_discovery do
        resources :namespaces, only: [], controller: 'cluster_namespaces' do
          resources :services, only: [:index, :show], controller: 'cluster_services'
        end
        resources :projects, only: [:index], controller: 'cluster_projects'
        resources :services, only: [:create, :update]
      end
    end
  end

  namespace :api_docs do
    get 'track.:format' => 'tracking#update', :as => :check
  end

  # only for the admin/buyers stuff that dont have admin in route name
  namespace :buyers, :as => 'admin', :path => 'admin/buyers' do
    resources :account_plans, :only => [:new, :create, :edit, :update, :destroy] do
      collection do
        post :masterize
      end
      member do
        post :copy
      end
    end
  end

  # These are API routes, beware
  namespace :stats do
    namespace :data, :path => '' do
      # horrible hacks with path to get parameter to be named :service_id
      resources :services, :path => 'services/:service_id' do  #, :applications do
        collection do
          get 'usage'
          get 'usage_response_code'
          get 'top_applications'
          get 'summary'
        end
      end
      resources :applications, :path => 'applications/:application_id' do
        collection do
          get 'usage'
          get 'usage_response_code'
          get 'summary'
        end
      end
      resources :backend_apis, :path => 'backend_apis/:backend_api_id' do
        collection do
          get 'usage'
        end
      end
    end
  end

  get '/check.txt' => 'checks#check'
  get '/check/error' => 'checks#error'
  get '/search/forum' => 'search#forum'

  namespace :admin do # this is different from the scope that follows as the controllers are in the admin module

    namespace :account do
      resource :payment_gateway, :only => [:update]
    end

    namespace :api_docs do
      resources :services, controller: 'account_api_docs' do
        member do
          get :preview
          put :toggle_visible
        end
      end
    end

    resources :web_hooks, :only => [:index, :create, :update] do
      member do
        post :ping
      end
    end
    resource :user_confirmation, :only => :create
    resources :fields_definitions do
      collection do
        post :sort
      end
    end

    resources :upgrade_notices, :only => [:show]

    # api routes, be careful
    namespace :api, :defaults => { :format => 'xml' } do

      get 'objects/status' => 'objects#status', as: :objects_status, controller: :objects, defaults: { format: :json }

      namespace :personal, defaults: { format: :json } do
        resources :access_tokens, except: %i[new edit]
      end

      # /admin/api/provider
      resource :provider, only: [:show, :update]

      resources :authentication_providers, except: %i[new edit destroy]

      namespace :account do
        resources :authentication_providers, except: %i[new edit destroy] do
          member do
            put :change_published
          end
        end
        resources :proxy_configs, path: 'proxy_configs/:environment', only: %i[index], defaults: { format: :json }
      end

      namespace(:cms) do
        resources :sections do
          resources :files, only: :index
          #resources :templates, only: :index
          #resources :sections, only: :index
        end
        resources :files
        resources :templates, :only => [ :index, :create, :show, :update, :destroy ] do
          member do
            put :publish
          end
        end
      end

      resources :sso_tokens, only: :create do
        collection do
          post :provider_create, constraints: MasterDomainConstraint
        end
      end

      resources :backend_apis, defaults: { format: :json } do
        scope module: :backend_apis do
          resources :metrics, except: %i[new edit] do
            resources :methods, controller: 'metric_methods', except: %i[new edit]
          end
          resources :mapping_rules, except: %i[new edit]
        end
      end

      resources :accounts, :only => [:index, :show, :update, :destroy] do
        collection do
          get :find
        end

        member do
          put :change_plan
          put :make_pending
          put :approve
          put :reject
        end

        resource :credit_card, :only => [:update, :destroy]
        resources :users, :controller => 'buyers_users', :except => [:new, :edit] do
          member do
            put :admin
            put :member
            put :suspend
            put :activate
            put :unsuspend
          end
        end

        resources :application_plans, :controller => 'buyers_application_plans', :only => :index do
          member do
            post :buy
          end
        end
        resource :plan, :as => 'buyer_account_plan',:controller => 'buyer_account_plans', :only => :show
        resources :service_plans, :controller => 'buyers_service_plans', :only => [:index] do
          member do
            post :buy
          end
        end

        resources :applications, :controller => 'buyers_applications', :except => :edit do
          collection do
            get :find
          end
          member do
            put :change_plan
            put :customize_plan
            put :decustomize_plan
            put :accept
            put :suspend
            put :resume
          end
          resources :keys, :controller => 'buyer_application_keys', :only => [:index, :create, :destroy]
          resources :referrer_filters, :controller => 'buyer_application_referrer_filters', :only => [:index, :create, :destroy]
        end

        resources :service_contracts, :only => [:index, :destroy]

        resources :messages, :only => [:create]
      end

      resources :account_plans, :except => [:new, :edit] do
        member do
          put :default
        end
        resources :features, :controller => 'account_plan_features', :only => [:index, :create, :destroy]
      end

      resources :active_docs, :controller => 'api_docs_services', except: %i[new edit]

      resources :policies, only: [:index]

      resources :application_plans, :only => [:index] do
        resources :pricing_rules, :controller => 'application_plan_pricing_rules', :only => [:index ]
        resources :features, :controller => 'application_plan_features', :only => [:index, :create, :destroy]
        resources :limits, :controller => 'application_plan_limits', :only => :index

        resources :metrics, :only => [] do
          resources :limits, :controller => 'application_plan_metric_limits', :except => [:new, :edit]
          resources :pricing_rules, controller: 'application_plan_metric_pricing_rules', only: %i[index create destroy]
        end
      end

      resources :applications, :only => [:index] do
        collection do
          get :find
        end
      end

      resource :signup, :only => :create
      resources :users, :except => [:new, :edit] do
        member do
          put :admin
          put :member
          put :suspend
          put :activate
          put :unsuspend
          resource :permissions, controller: 'member_permissions', only: [:show, :update]
        end

        resources :access_tokens, only: %i[create]
      end

      resources :service_plans, :only => [:index] do
        resources :features, :controller => 'service_plan_features', :only => [:index, :create, :destroy]
      end

      resources :features, :controller => 'account_features', :except => [:new, :edit]

      resource :nginx, :only => [:show], :defaults => { :format => 'zip' } do
        collection do
          get :spec
        end
      end

      resources :services, :except => [:new, :edit] do
        resources :metrics, :except => [:new, :edit] do
          resources :methods, :controller => 'metric_methods', :except => [:new, :edit]
        end

        resources :features, :controller => 'service_features', :except => [:new, :edit]

        resources :service_plans, :except => [:new, :edit] do
          member do
            put :default
          end
        end

        resources :application_plans, :except => [:new, :edit] do
          member do
            put :default
          end
        end

        scope module: :services do # this api has a knack for inconsistency
          resources :backend_usages, except: %i[new edit], defaults: { format: :json }

          resource :proxy, only: %i[show update] do
            post :deploy
            resources :mapping_rules, only: %i[index show update destroy create]
          end

          namespace :proxy do

            resources :policies, only: [] do
              get :show, on: :collection
              put :update, on: :collection
            end

            resources :configs, param: :version, path: 'configs/:environment', only: [:index, :show] do
              get :latest, on: :collection
              post :promote, on: :member
            end

            resource :oidc_configuration, only: %i[show update]
          end

          collection do
            namespace :proxy do
              resources :configs, param: :version, path: 'configs/:environment', only: [] do
                get :index, on: :collection, action: :index_by_host
              end
            end
          end
        end

      end
      resource :webhooks, controller: 'web_hooks', only: [:update] do
        resource :failures, controller: 'web_hooks_failures', only: [:show, :destroy]
      end
      resource :settings, only: [:show, :update]

      namespace :registry, defaults: { format: :json } do
        constraints(id: /((?!\.json\Z)[^\/])+/) do
          resources :policies, except: %i[new edit]
        end
      end
    end
  end

  # TODO: move this route to DeveloperPortal when this
  # functionality is completely removed from the provider
  # side (it is currently only guarding edge environment
  match 'access_code' => 'developer_portal/access_codes#show', :as => :access_code, :via => [:post, :get]

  constraints MasterOrProviderDomainConstraint do

    namespace :api_docs do
      resources :services, only: [:index, :show]
    end

    match '/api_docs/proxy' => 'api_docs/proxy#show', via: [:get, :post]

    admin_module = -> do
      scope :path => 'apiconfig', :module => 'api' do
        get '/' => 'services#index', :as => :apiconfig_root, :namespace => 'api/', :path_prefix => 'admin/apiconfig'
        resources :plans, :only => [] do
          member do
            post :publish
            post :hide
          end
          resources :features, :except => [:index]
          resources :featurings, :only => [:create, :destroy]
        end

        resources :plan_copies, :only => [:new, :create]
        resources :service_plans, :only => [:show, :edit, :update, :destroy]
        resources :application_plans, :only => [:show, :edit, :update, :destroy]

        resources :application_plans, only: [] do
          resources :metrics, only: [] do
            resource :metric_visibility, only: [], path: '', as: 'visibility' do
              member do
                put :toggle_visible
                put :toggle_enabled
                put :toggle_limits_only_text
              end
            end

            resources :pricing_rules, only: %i[index new create]
            resources :usage_limits, only: %i[index new create]
          end

          resources :pricing_rules, only: %i[edit update destroy]
          resources :usage_limits, only: %i[edit update destroy]
        end

        resources :services do
          member do
            get :settings
            get :usage_rules
          end
          resource :support, :only => [:edit, :update]
          resource :content, :only => [:edit, :update]
          resource :terms, :only => [:edit, :update]
          resources :metrics, :except => [:show] do
            resources :children, :controller => 'metrics', :only => [:new, :create]
          end

          resources :application_plans, :only => [:index, :new, :create] do
            collection do
              post :masterize
            end
            member do
              post :copy
            end
          end

          resources :service_plans, :only => [:index, :new, :create] do
            collection do
              post :masterize
            end
            member do
              post :copy
            end
          end

          resources :alerts, :only => [:index, :destroy] do
            collection do
              put :all_read
              delete :purge
            end
            member do
              put :read
            end
          end

          resources :applications, only: %i[index show edit]
          resources :api_docs, only: %i[index new edit update create], controller: '/admin/api_docs/service_api_docs' do
            member do
              get :preview
            end
          end

          resources :errors, only: :index do
            collection do
              delete :purge, path: ''
            end
          end

          resources :backend_usages, except: :show

          resource :integration, except: %i[create destroy edit] do
            member do
              patch 'promote_to_production'
              patch 'toggle_apicast_version'
            end
          end
          resources :proxy_logs, :only => [:index, :show ]
          resources :proxy_configs, only: %i(index show)
          resources :proxy_rules, except: %i[show], defaults: { owner_type: 'Proxy' }
          resource :policies, except: [:show, :destroy]
        end

        resources :alerts, :only => [:index, :destroy] do
          collection do
            put :all_read
            delete :purge
          end
          member do
            put :read
          end
        end
      end # end scope :api

      resources :services, :only => [] do
        namespace :stats do
          get '/signups' => 'dashboards#signups', :as => :signups
          get 'usage' => 'usage#index', :as => :usage
          get 'usage/data/:metric_id' => 'usage#index_data', :as => :usage_data
          get 'usage/top_applications' => 'usage#top_applications', :as => :top_applications
          get 'usage/hours' => 'usage#hours', :as => :hours
          resources :days, :only => :index
          get 'days/:id/:metric_id' => 'days#show', :as => :day
          resource :response_codes, only: [:show]
        end
      end # end resources :services

      # to kind of live under buyers namespace, but do not share the Buyers module
      namespace :stats, as: :buyers_stats, path: 'buyers/stats' do
        resources :applications, :only => :show
      end

      namespace :buyers do
        resources :accounts do
          member do
            post :approve
            post :reject
            post :suspend
            post :resume
            put :toggle_monthly_billing
            put :toggle_monthly_charging
          end

          resource :impersonation, :only => [:create]

          resources :users, :except => [:new, :create] do
            member do
              post :suspend
              post :unsuspend
              post :activate
            end
          end

          resources :configs, :only => [:index, :update, :destroy]
          resources :invitations, :only => [:index, :new, :create, :destroy] do
            member do
              put :resend
            end
          end

          resources :applications, except: %i[show edit]

          resources :service_contracts, :except => [:show] do
            member do
              put :change_plan
              post :approve
            end
          end

          resources :invoices, :only => [:index, :show, :create, :edit, :update]
          resource :groups, :only => [:show, :update]
        end

        namespace :accounts do
          namespace :bulk do
            resource :send_email, :only => [:new, :create]
            resource :change_plan, :only => [:new, :create]
            resource :change_state, :only => [:new, :create]
            resource :delete, :only => [:new, :create]
          end
        end
        resources :account_contracts, :only => :update
        resources :account_plans, :only => [:index, :new, :create] do
          collection do
            post :masterize
          end
        end
        resources :service_contracts, :only => [:index]
        resources :contracts, :only => [] do
          resources :custom_plans, :only => [:create, :destroy]
          resources :custom_application_plans, :only => [:create, :destroy]
        end
        resources :applications do

          member do
            put :accept
            delete :reject
            post :suspend
            post :resume
            put :change_user_key
            put :change_plan
            get :edit_redirect_url
          end

        end
        namespace :applications do
          namespace :bulk do
            resource :send_email, :only => [:new, :create]
            resource :change_plan, :only => [:new, :create]
            resource :change_state, :only => [:new, :create]
          end
        end
        namespace :service_contracts do
          namespace :bulk do
            resource :send_email, :only => [:new, :create]
            resource :change_plan, :only => [:new, :create]
            resource :change_state, :only => [:new, :create]
          end
        end
      end # end namespace :buyers

      namespace :finance do
        root :to => 'provider/dashboards#show'

        scope :module => 'provider' do
          resources :invoices, :only => [:index, :show, :update, :create, :edit] do
            member do
              put :pay
              put :generate_pdf
              put :cancel
              put :charge
              put :issue
            end
            resources :line_items, :only => [:new, :create, :destroy]
          end

          resources :accounts, :only => [] do
            resources :invoices, :only => [:index, :show, :update, :create] do
              # member do
              #   put :pay
              #   put :generate_pdf
              #   put :cancel
              #   put :charge
              #   put :issue
              # end
              resources :line_items, :only => [:new, :create, :destroy]
            end
          end

          resource :settings
          resources :log_entries, :only => :index
          resource :billing_strategy, :only => :update
        end
      end # end namespace :finance

      scope :module => 'forums' do
        scope :module => 'admin' do
          resource :forum do
            resources :categories
            resources :posts, :only => [:index, :edit, :update, :destroy]
            resources :topics, :except => :index do
              collection do
                get :my
              end

              resources :posts, :only => :create
            end

            resources :subscriptions, :controller => 'user_topics', :only => [:index, :create, :destroy]
          end
        end
      end # end scope :forums

      namespace :site, :module => 'sites' do # the controller is in the sites module, not site *sigh*

        resource :usage_rules, only: [:edit, :update]
        resource :settings, only: [:show, :edit, :update] do
          member do
            get :policies
          end
        end

        resource :applications, only: [:edit, :update]
        resource :documentation, only: [:edit, :update]


        resource :developer_portal, only: [:edit, :update]

        resource :dns, only: [:show, :update] do
          member do
            put :open_portal
            get :contact_3scale
          end
        end
        resource :forum, only: [:edit, :update]
        resource :spam_protection, only: [:edit, :update]
        resource :emails, only: [ :edit, :update ]
      end
    end
    scope as: :admin, &admin_module

    # Finance API
    scope :module => 'finance' do
      namespace :api do
        resources :invoices, :only => [:index, :show, :update, :create] do
          resources :payment_transactions, only: :index
          resources :line_items, only: [:index, :create, :destroy]
          member do
            put :state
            post :charge
          end
        end

        namespace 'payment_callbacks', module: 'payment_callbacks' do
          resources :stripe_callbacks, only: :create
        end

        resources :accounts, :only => [], module: 'accounts' do
          resources :invoices, :only => [:index, :show]
        end
      end
    end
  end

  constraints BuyerDomainConstraint do

    scope :module => 'forums' do
      scope :module => 'public' do
        resource :forum, :only => "show" do
          resources :categories, only: [:index, :show]
          resources :posts, :only => [:index, :edit, :update, :destroy]
          resources :topics, :except => :index do
            collection do
              get :my
            end
            resources :posts, :only => [:create]
          end
          resources :subscriptions, :controller => 'user_topics', :only => [:index, :create, :destroy]
        end
      end
    end

    mount DeveloperPortal::Engine, at: "/", as: :developer_portal
  end

  if Rails.env.development? || Rails.env.test?
    mount MailPreview => 'mail_preview'
  end
end

# rubocop:enable Metrics/BlockLength
