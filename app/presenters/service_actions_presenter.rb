# frozen_string_literal: true

class ServiceActionsPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(user)
    @ability = Ability.new(user)
  end

  def actions(product)
    actions = []

    actions << { name: 'Edit', path: edit_admin_service_path(product) } if can?(:manage, :plans)
    actions << { name: 'Overview', path: admin_service_path(product) } if can?(:manage, :plans)
    actions << { name: 'Analytics', path: admin_service_stats_usage_path(product) } if can?(:manage, :monitoring)

    if can?(:manage, :applications)
      actions << { name: 'Applications', path: admin_service_applications_path(product) }
    elsif can?(:manage, :plans)
      actions << { name: 'Applications', path: admin_service_application_plans_path(product) }
    end

    actions << { name: 'ActiveDocs', path: admin_service_api_docs_path(product) } if can?(:manage, :plans)
    actions << { name: 'Integration', path: admin_service_integration_path(product) } if can?(:manage, :plans)

    actions
  end

  def backend_actions(backend)
    actions = []
    can_edit_backend = can?(:edit, backend)
    actions << { name: 'Overview', path: provider_admin_backend_api_path(backend) } if can?(:read, backend)
    actions << { name: 'Edit', path: edit_provider_admin_backend_api_path(backend) } if can_edit_backend
    actions << { name: 'Analytics', path: provider_admin_backend_api_stats_usage_path(backend) } if can?(:manage, :monitoring) || can?(:manage, :monitoring)
    actions << { name: 'Methods and Metrics', path: provider_admin_backend_api_metrics_path(backend) } if can_edit_backend
    actions << { name: 'Mapping Rules', path: provider_admin_backend_api_mapping_rules_path(backend) } if can_edit_backend

    actions
  end

  private

  delegate :can?, to: :ability

  attr_reader :ability
end
