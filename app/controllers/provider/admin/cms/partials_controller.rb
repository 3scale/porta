class Provider::Admin::CMS::PartialsController < Provider::Admin::CMS::TemplatesController

  private
  def templates
    current_account.partials
  end

  def allowed_params
    %i[system_name draft].freeze
  end

end
