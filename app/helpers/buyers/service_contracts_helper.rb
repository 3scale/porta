# rubocop:disable Layout/ArgumentAlignment
# frozen_string_literal: true

# TODO: move this into service_contracts_index_presenter.rb

module Buyers::ServiceContractsHelper
  def admin_subscribe_service_link(account, service)
    action_link_to :subscribe, new_admin_buyers_account_service_contract_path(account, service_id: service.id),
                               class: 'new fancybox',
                               title: "Subscribe to #{service.name}"
  end

  def admin_change_service_plan_link(contract, service)
    action_link_to :change_plan, edit_admin_buyers_account_service_contract_path(contract.account, contract),
                                 class: 'edit fancybox',
                                 title: "Change #{service.name} subscription"
  end

  def admin_approve_pending_service_contract_link(contract, service)
    action_link_to 'approve', approve_admin_buyers_account_service_contract_path(contract.account, contract),
                              method: :post,
                              title: "Approve subscription to #{service.name}"
  end

  def admin_delete_service_contract_link(contract)
    action_link_to :delete, admin_buyers_account_service_contract_path(contract.account, contract),
                            'data-confirm': "Are you sure? Unsubscribing will delete all this account's applications that subscribe to this service (applications need to be suspended beforehand)",
                            'data-method': :delete,
                            label: 'Unsubscribe',
                            title: "Unsubscribe from #{contract.service.name}"
  end
end

# rubocop:enable Layout/ArgumentAlignment
