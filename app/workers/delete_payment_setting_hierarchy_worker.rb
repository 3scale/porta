# frozen_string_literal: true

class DeletePaymentSettingHierarchyWorker < DeleteObjectHierarchyWorker
  private

  alias payment_setting object

  def delete_associations
    super

    return unless called_from_provider_hierarchy?

    reflection_buyers_of_provider = Account.reflect_on_all_associations.find { |reflection| reflection.name == :buyer_accounts }
    ReflectionDestroyer.new(payment_setting.account, reflection_buyers_of_provider, caller_worker_hierarchy).destroy_later
  end
end
