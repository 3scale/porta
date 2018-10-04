# frozen_string_literal: true

class Admin::ApiDocs::AccountApiDocsController < Admin::ApiDocs::BaseController
  class NotImplementedServiceScopeError < NotImplementedError; end
  rescue_from(NotImplementedServiceScopeError) do |exception|
    System::ErrorReporting.report_error(exception)
    handle_not_found
  end

  before_action :redirect_to_service_scope, if: :service, only: %i[edit preview]

  private

  def redirect_to_service_scope
    flash.keep
    case action_name.to_sym
    when :preview
      redirect_to preview_admin_service_api_doc_path(service, api_docs_service)
    when :edit
      redirect_to edit_admin_service_api_doc_path(service, api_docs_service)
    else
      raise NotImplementedServiceScopeError, "#{action_name} redirection for ApiDoc under Service scope is not implemented"
    end
  end

  def service
    api_docs_service.service
  end

  def current_scope
    current_account
  end
end
