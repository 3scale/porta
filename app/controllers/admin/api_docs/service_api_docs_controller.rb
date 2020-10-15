# frozen_string_literal: true

class Admin::ApiDocs::ServiceApiDocsController < Admin::ApiDocs::BaseController
  prepend_before_action :find_service

  activate_menu :serviceadmin, :ActiveDocs
  sublayout 'api/service'

  def index
    @api_docs_services = api_docs_collection.page(params[:page])
  end

  private

  def find_api_docs
    @api_docs_service = current_scope.account.all_api_docs.find_by_id_or_system_name!(params[:id])
  end

  def current_scope
    @service
  end

  def api_docs_collection
    current_scope.api_docs.service_accessible.permitted_for(current_user)
  end
end
