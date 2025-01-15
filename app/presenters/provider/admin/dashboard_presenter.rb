# frozen_string_literal: true

class Provider::Admin::DashboardPresenter
  include System::UrlHelpers.system_url_helpers

  WIDGET_SIZE = 5

  def initialize(user:)
    @user = user
    @ability = Ability.new(user)

    @products = user.accessible_services
                    .order('updated_at desc')
                    .limit(WIDGET_SIZE)

    @backend_apis = user.accessible_backend_apis
                        .order('updated_at desc')
                        .limit(WIDGET_SIZE)

    @service_actions_presenter = ServiceActionsPresenter.new(user)
  end

  attr_reader :products, :backend_apis

  def products_widget_data
    {
      products: products.map do |product|
        {
          id: product.id,
          name: product.name,
          updated_at: product.updated_at.to_s(:long),
          link: product.decorate.link,
          links: service_actions_presenter.actions(product)
        }
      end,
      newProductPath: can_create_service ? new_admin_service_path : nil,
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
          updated_at: backend.updated_at.to_s(:long),
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

  private

  attr_reader :user, :ability, :service_actions_presenter

  delegate :can?, to: :ability

  # See https://github.com/3scale/porta/blob/27c0e3ab66e6d589412b2e87ee86e32c1f7f5390/app/controllers/api/services_controller.rb#L165
  def can_create_service
    can?(:create, Service)
  end
end
