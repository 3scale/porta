class Stats::ResponseCodesController < Stats::ServiceBaseController

  before_action :find_service

  activate_menu :serviceadmin, :monitoring, :response_codes
end
