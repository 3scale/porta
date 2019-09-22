# frozen_string_literal: true

class DeleteServiceHierarchyWorker < DeleteObjectHierarchyWorker
  def perform(*)
    purge_backend_apis unless service.account.provider_can_use?(:api_as_product)
    super
  end

  private

  alias service object

  def purge_backend_apis
    BackendApi.of_product(service).accessible.find_each(&:mark_as_deleted!)
  end
end
