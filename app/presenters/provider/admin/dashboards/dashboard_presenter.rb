# frozen_string_literal: true

class Provider::Admin::Dashboards::DashboardPresenter
  include System::UrlHelpers.system_url_helpers

  WIDGET_SIZE = 5
  MESSAGES_LIMIT = 16
  IGNORED_NOTIFICATIONS = %w[csv_data_export daily_report weekly_report].freeze

  def initialize(user:) # rubocop:disable Metrics/AbcSize
    @user = user
    @ability = Ability.new(user)

    @products = user.accessible_services
                    .order(updated_at: :desc)
                    .limit(WIDGET_SIZE)

    @backend_apis = user.accessible_backend_apis
                        .order(updated_at: :desc)
                        .limit(WIDGET_SIZE)

    @service_actions_presenter = ServiceActionsPresenter.new(user)

    notifications = user.notifications.where.not(system_name: IGNORED_NOTIFICATIONS)
                                      .where.not(title: nil)
                                      .order(created_at: :desc)
                                      .limit(MESSAGES_LIMIT)

    @todays_messages, @older_messages = notifications.partition do |message|
      message.created_at.today?
    end
  end

  attr_reader :products, :backend_apis, :todays_messages, :older_messages

  def products_widget_data
    {
      products: products.map do |product|
        {
          id: product.id,
          name: product.name,
          updated_at: product.updated_at.to_fs(:long),
          link: product.decorate.link,
          links: service_actions_presenter.actions(product)
        }
      end,
      newProductPath: can?(:create, Service) ? new_admin_service_path : nil,
      productsPath: admin_services_path
    }
  end

  def backends_widget_data
    {
      accessToBackends: true,
      backends: backend_apis.map do |backend|
        {
          id: backend.id,
          name: backend.name,
          updated_at: backend.updated_at.to_fs(:long),
          link: backend.decorate.link,
          links: service_actions_presenter.backend_actions(backend)
        }
      end,
      newBackendPath: can?(:create, BackendApi) ? new_provider_admin_backend_api_path : nil,
      backendsPath: provider_admin_backend_apis_path
    }
  end

  def can_see_audience_section?
    can?(:manage, :partners) || can?(:manage, :finance) || can?(:manage, :portal) || can?(:manage, :settings)
  end

  def access_to_products?
    user.access_to_service_admin_sections?
  end

  def access_to_backends?
    can?(:read, BackendApiConfig) || can?(:manage, :monitoring)
  end

  def no_messages_message
    index = Rails.env.test? ? 1 : rand(1..6)
    I18n.t("provider.admin.dashboards.show.no_messages_#{index}")
  end

  private

  attr_reader :user, :ability, :service_actions_presenter

  delegate :can?, to: :ability
end
