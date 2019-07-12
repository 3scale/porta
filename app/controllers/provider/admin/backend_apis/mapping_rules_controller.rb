# frozen_string_literal: true

class Provider::Admin::BackendApis::MappingRulesController < Provider::Admin::BackendApis::BaseController
  activate_menu :backend_api, :mapping_rules

  def index
    @service = @backend_api.service # FIXME: This is needed because the page is still using a partial shared with the old integration view (with mapping rules embedded)
  end
end
