class  Provider::Admin::Onboarding::Wizard::InfoController < Provider::Admin::Onboarding::Wizard::BaseController

  def index
    flash.keep
    redirect_to action: :intro
  end

  def intro
    track_step('intro')
  end

  def explain
    @proxy = proxy
    track_step('explain')
  end

  def outro
    track_step('outro')
  end

  protected

  def proxy
    current_account.first_service!.proxy
  end
end
