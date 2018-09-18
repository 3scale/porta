# TODO: those controllers are service specific and routed elsewhere -
# move them to the right namespace
#
class Stats::BaseController < FrontendController
  helper_method :since
  before_action :set_utc_offset

  protected

  def since
    Date.parse(params.fetch(:since) { return 30.days.ago })
  end

  def set_utc_offset
    @utc_offset = ActiveSupport::TimeZone.new(current_account.timezone).utc_offset
  end
end
