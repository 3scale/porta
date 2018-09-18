class Admin::Api::HerokuProxyController < Admin::Api::BaseController
  # https://github.com/3scale/oneclick-api-gateway-heroku will call this method
  # when proxy has been deployed to Heroku as a heroku deploy hook

  def deployed
    step = :heroku_proxy_deployed
    go_live_state = current_account.go_live_state

    if go_live_state.can_advance_to?(step)
      go_live_state.advance(step, final_step=true)
      ThreeScale::Analytics.track_account(current_account, "golive:#{step}")
    end

    render nothing: true, status: :ok
  end
end
