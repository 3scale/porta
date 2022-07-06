# frozen_string_literal: true

class PlanBaseDecorator < ApplicationDecorator
  def index_table_data
    {
      id: id,
      name: name,
      editPath: h.edit_polymorphic_path([:admin, object]),
      contracts: contracts_count,
      contractsPath: contracts_path,
      state: state,
      actions: index_table_actions
    }
  end

  def index_table_actions
    [
      published? ? nil : { title: 'Publish', path: h.publish_admin_plan_path(object), method: :post },
      published? ? { title: 'Hide', path: h.hide_admin_plan_path(object), method: :post } : nil,
      { title: 'Copy', path: h.admin_plan_copies_path(plan_id: id), method: :post },
      can_be_destroyed? ? { title: 'Delete', path: h.polymorphic_path([:admin, object]), method: :delete } : nil
    ].compact
  end

  def contracts_path
    raise NoMethodError, "#{__method__} not implemented in #{self.class}"
  end
end
