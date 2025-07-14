# frozen_string_literal: true

class Api::ErrorsIndexPresenter
  include ::Draper::ViewHelpers

  def initialize(errors:, service:)
    @errors = errors
    @service = service
  end

  attr_reader :errors, :service

  def empty_state?
    errors.empty?
  end

  def toolbar_props
    {
      totalEntries: errors.total_entries,
      pageEntries: errors.length,
      actions: [{
        variant: :danger,
        label: I18n.t('api.errors.index.toolbar.purge.title'),
        href: h.admin_service_errors_path(service),
        'data-confirm': I18n.t('api.errors.index.toolbar.purge.confirm'),
        'data-method': :delete,
      }],
    }
  end
end
