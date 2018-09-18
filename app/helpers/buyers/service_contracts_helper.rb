module Buyers::ServiceContractsHelper
  def admin_subscribe_service_link(account, service)
    action_link_to :subscribe, new_admin_buyers_account_service_contract_path(account, :service_id => service.id),
      :class => 'new fancybox', :title => "Subscribe to #{service.name}"
  end

  def admin_change_service_plan_link(account, service, contract)
    action_link_to :change_plan, edit_admin_buyers_account_service_contract_path(account, contract),
      :class => 'edit fancybox', :title => "Change #{service.name} subscription"
  end
end
