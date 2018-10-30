# frozen_string_literal: true

class Admin::ApiDocs::ServiceApiDocsController < Admin::ApiDocs::BaseController
  prepend_before_action :find_service

  activate_menu :serviceadmin, :ActiveDocs
  sublayout 'api/service'

  private

  def current_scope
    @service
  end
end
