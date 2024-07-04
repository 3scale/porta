# frozen_string_literal: true

class Admin::Api::ObjectsController < Admin::Api::BaseController
  clear_respond_to
  respond_to :json

  ALLOWED_OBJECTS = %w[service account proxy backend_api].freeze

  before_action :authorize!

  # Object deletion status for objects that are deleted asynchronously
  # GET /admin/api/objects/status.json
  def status
    status_object = status_object_type.classify.constantize.select(:tenant_id).unscoped.find(status_object_id)

    authorize_tenant!(status_object)

    head(:ok)
  end

  private

  def status_object_type
    @status_object_type ||= params.fetch(:object_type).to_s
  end

  def status_object_id
    @status_object_id ||= params.fetch(:object_id)
  end

  def authorize_tenant!(status_object)
    raise_access_denied if !current_account.master? && current_account.tenant_id != status_object.tenant_id
  end

  def authorize!
    raise_access_denied if unknown_status_object || current_user_not_admin
  end

  def unknown_status_object
    ALLOWED_OBJECTS.exclude?(status_object_type)
  end

  def current_user_not_admin
    !current_user&.admin?
  end

  def raise_access_denied
    raise CanCan::AccessDenied
  end
end
