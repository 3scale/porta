# frozen_string_literal: true

class DeleteServiceHierarchyWorker < DeleteObjectHierarchyWorker
  private

  alias service object

  # TODO: when we remove the Rolling Update, we must remove this whole method and not only the conditional
  def destroyable_associations
    return super if service.account.provider_can_use?(:api_as_product)

    object.class.reflect_on_all_associations.select do |reflection|
      reflection.options[:dependent] == :destroy || reflection.name == :backend_apis
    end
  end
end
