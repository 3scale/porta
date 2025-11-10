# frozen_string_literal: true

class Admin::ApiDocs::ServiceApiDocsController < Admin::ApiDocs::BaseController
  prepend_before_action :find_service

  activate_menu :serviceadmin, :ActiveDocs

  before_action :disable_client_cache, only: :preview

  private

  def current_scope
    @service
  end
end
