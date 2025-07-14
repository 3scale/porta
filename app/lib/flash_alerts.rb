# frozen_string_literal: true

module FlashAlerts
  extend ActiveSupport::Concern

  ALERT_TYPES = %i[default info warning success danger].freeze

  included do
    add_flash_types(*ALERT_TYPES)
    helper_method :alert_type?
  end

  private

  def alert_type?(type)
    ALERT_TYPES.include?(type.to_sym)
  end
end
