# frozen_string_literal: true

class DeletePaymentSettingHierarchyWorker < DeleteObjectHierarchyWorker
  private

  alias payment_setting object

  def destroy_and_delete_associations
    super

    return unless called_from_provider_hierarchy?

    reflection = BackgroundDeletion::Reflection.new([:buyer_accounts, { action: :destroy, class_name: 'Account' }])
    ReflectionDestroyer.new(object.account, reflection, caller_worker_hierarchy).destroy_later
  end
end
