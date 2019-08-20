# frozen_string_literal: true

class Provider::Admin::BackendApis::MappingRulesController < Provider::Admin::BackendApis::BaseController
  activate_menu :backend_api, :mapping_rules

  include ThreeScale::Search::Helpers

  def index
    @mapping_rules = @backend_api.mapping_rules
                                 .order_by(params[:sort], params[:direction])
                                 .includes(:metric)
                                 .paginate(pagination_params)
  end
end
