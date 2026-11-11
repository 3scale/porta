# frozen_string_literal: true

module AccountSetting::Concerns::SensitiveAudit
  extend ActiveSupport::Concern

  FILTERED = '[FILTERED]'

  def audited_attributes
    super.transform_values { _1.nil? ? nil : FILTERED }
  end

  private

  def audited_changes(...)
    super.transform_values { _1.map { |el| el.nil? ? nil : FILTERED } }
  end
end
