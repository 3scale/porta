# frozen_string_literal: true

module Deletion
  class ReflectionDestroyerService

    def initialize(main_object, reflection, caller_worker_hierarchy)
      @main_object = main_object
      @reflection = reflection
      @caller_worker_hierarchy = caller_worker_hierarchy
    end

    def destroy_later
      reflection.many? ? destroy_has_many_association : destroy_has_one_association
    end

    def self.call(*args)
      new(*args).destroy_later
    end

    attr_reader :main_object, :reflection, :caller_worker_hierarchy

    private

    def destroy_has_many_association
      main_object.public_send("#{reflection.name.to_s.singularize}_ids").each do |associated_object_id|
        associated_object = reflection.class_name.constantize.new
        associated_object.id = associated_object_id
        delete_associated_object_later(associated_object)
      end
    rescue ActiveRecord::UnknownPrimaryKey => exception
      Rails.logger.info "DeleteObjectHierarchyWorker#perform raised #{exception.class} with message #{exception.message}"
    end

    def destroy_has_one_association
      associated_object = main_object.public_send(reflection.name)
      delete_associated_object_later(associated_object)
    end

    def delete_associated_object_later(associated_object)
      association_delete_worker.perform_later(associated_object, caller_worker_hierarchy, reflection.background_destroy_method) if associated_object.try(:id)
    end

    def association_delete_worker
      case reflection.class_name
      when Account.name
        DeleteAccountHierarchyWorker
      when PaymentGatewaySetting.name
        DeletePaymentSettingHierarchyWorker
      else
        DeleteObjectHierarchyWorker
      end
    end
  end

end
