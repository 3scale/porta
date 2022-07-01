# frozen_string_literal: true

class DeleteAccountHierarchyWorker < DeleteObjectHierarchyWorker
  def perform(*)
    return unless account.should_be_deleted?
    super
  end

  private

  alias account object

  def batch_description
    id = account.id
    org_name = account.org_name
    if account.provider?
      "Deleting provider [##{id}] #{org_name} - #{account.external_admin_domain}"
    else
      "Deleting buyer [##{id}] of provider #{org_name}"
    end
  end

  def destroyable_association?(association)
    if called_from_provider_hierarchy? && account.gateway_setting.persisted?
      association != :buyer_accounts
    else
      super
    end
  end
end
