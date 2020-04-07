# frozen_string_literal: true

class Provider::Admin::BackendApis::Stats::UsageController < Provider::Admin::BackendApis::Stats::BaseController
  activate_menu :backend_api, :monitoring, :usage
end
