# frozen_string_literal: true

class MetricDecorator < ApplicationDecorator

  self.include_root_in_json = false

  def new_mapping_rule_data
    {
      id: id,
      name: friendly_name,
      systemName: system_name,
      updatedAt: updated_at
    }
  end

  def mapped?
    owner.proxy.proxy_rules.map(&:metric).include?(self)
  end
end
