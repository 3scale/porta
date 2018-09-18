class Provider::Admin::CMS::PartialsController < Provider::Admin::CMS::TemplatesController

  private
  def templates
    current_account.partials
  end

end
