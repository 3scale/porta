# frozen_string_literal: true

class DeleteServiceHierarchyWorker < DeleteObjectHierarchyWorker
  private

  alias service object

  # TODO: when we remove the Rolling Update, we must remove this whole method
  def destroyable_association?(reflection)
    super || (reflection.name == :backend_apis && !service.account.provider_can_use?(:api_as_product))
  end
end
