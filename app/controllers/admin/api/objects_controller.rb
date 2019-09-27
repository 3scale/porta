# frozen_string_literal: true

class Admin::Api::ObjectsController < Admin::Api::BaseController

  class AllowedStatusObject
    attr_reader :controller, :status_object

    def initialize(controller, status_object)
      @controller = controller
      @status_object = status_object
    end

    def authorize
      raise NotImplementedError
    end

    private

    def raise_access_denied
      raise CanCan::AccessDenied
    end
  end

  class BuyerAccountObject < AllowedStatusObject
    def authorize
      controller.authorize! :read, status_object
    end
  end

  class ServiceObject < AllowedStatusObject
    def authorize
      raise_access_denied unless controller.accessible_services.exists?(service_id)
    end

    def service_id
      controller.status_object_id
    end
  end

  class ProxyObject < ServiceObject
    delegate :service_id, to: :status_object
  end

  class BackendApiObject < AllowedStatusObject
    def authorize
      controller.provider_can_use!(:api_as_product)
    end
  end

  ALLOWED_OBJECTS = %w[service buyer_account proxy backend_api].freeze

  before_action :authorize_status_object_type

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/objects/status.json"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Object deletion status for objects that are deleted asynchronously"
  ##~ op.description = "Returns an object status. (200/404). Useful for those objects that deleted asynchronously in order to know if the deletion has been completed(404) or not(200)"
  ##~ op.group = "objects"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :dataType => "string", :required => true, :paramType => "query", :name => "object_type", :description => "Object type has to be service, buyer_account, proxy or backend_api."
  ##~ op.parameters.add :dataType => "string", :required => true, :paramType => "query", :name => "object_id", :description => "Object ID."
  def status
    status_object = current_account.public_send(association_name).find(status_object_id)

    authorize_status_object(status_object)

    head :ok
  end

  def status_object_type
    @status_object_type ||= params.fetch(:object_type).to_s
  end

  def status_object_id
    @status_object_id ||= params.fetch(:object_id)
  end

  private

  def association_name
    status_object_type.pluralize
  end

  def authorize_status_object_type
    raise(CanCan::AccessDenied) if ALLOWED_OBJECTS.exclude?(status_object_type)
  end

  def authorize_status_object(status_object)
    "#{self.class}::#{status_object_type.classify}Object".constantize.new(self, status_object).authorize
  end
end
