# frozen_string_literal: true

class DeletePaymentSettingHierarchyWorker < DeleteObjectHierarchyWorker
  private

  alias payment_setting object

  def destroy_and_delete_associations
    super

    return unless called_from_provider_hierarchy?

    reflection = BackgroundDeletion::Reflection.new([:buyer_accounts, { action: :destroy, class_name: 'Account' }])
    Deletion::ReflectionDestroyerService.call(object.account, reflection, caller_worker_hierarchy)
  end
end
