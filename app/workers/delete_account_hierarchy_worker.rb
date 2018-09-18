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
      "Deleting provider [##{id}] #{org_name} - #{account.admin_domain}"
    else
      "Deleting buyer [##{id}] of provider #{org_name}"
    end
  end

end
