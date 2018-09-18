class Provider::Admin::DestroysController < Provider::Admin::BaseController

  before_action :activate_menu_for_destroys

  ALLOWED_KINDS = { 'accounts' => 'Account', 'apps' => 'Cinstance', 'users' => 'User' }.freeze

  def index
    @destroy_type = kind
    @kind = ALLOWED_KINDS.fetch(@destroy_type).constantize.model_name
    @destroys = current_account.provider_audits.destroys
        .order('audits.id desc').where(kind: @kind.to_s).paginate(page: params[:page])
  end

  private

  def kind
    if ALLOWED_KINDS.has_key?(params[:kind])
      params[:kind]
    else
      'accounts'
    end
  end

  def activate_menu_for_destroys
    case kind
    when 'apps'
      self.activate_menu :applications
    else
      self.activate_menu :buyers
    end
  end
end
