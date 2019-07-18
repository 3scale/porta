# frozen_string_literal: true

class DeletePaymentSettingHierarchyWorker < DeleteObjectHierarchyWorker
  alias payment_setting object

  def delete_associations
    destroy_users_of_provider(payment_setting.account) if called_from_provider_hierarchy?

    super
  end

  private

  def called_from_provider_hierarchy?
    caller_worker_hierarchy.include?("Hierarchy-Account-#{payment_setting.account_id}")
  end

  def destroy_users_of_provider(provider)
    provider.buyer_account_ids.each do |associated_object_id|
      associated_object = Account.new
      associated_object.id = associated_object_id
      DeleteAccountHierarchyWorker.perform_later(associated_object, caller_worker_hierarchy)
    end
  end

end
