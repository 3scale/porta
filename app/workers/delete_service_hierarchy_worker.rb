# frozen_string_literal: true

class DeleteServiceHierarchyWorker < DeleteObjectHierarchyWorker
  private

  alias service object

  # TODO: when we remove the Rolling Update, we must remove this whole method
  def destroy_and_delete_associations
    unless service.account.provider_can_use?(:api_as_product)
      reflection = BackgroundDeletion::Reflection.new(:backend_apis)
      ReflectionDestroyer.new(service, reflection, caller_worker_hierarchy).destroy_later
    end

    super
  end
end
