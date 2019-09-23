# frozen_string_literal: true

class DeleteServiceHierarchyWorker < DeleteObjectHierarchyWorker
  def perform(*)
    # TODO: when we remove the Rolling Update, we must remove this whole line and not only the conditional
    purge_backend_apis unless service.account.provider_can_use?(:api_as_product)
    super
  end

  private

  alias service object

  def purge_backend_apis
    service.backend_apis.accessible.find_each(&:mark_as_deleted!)
  end
end
