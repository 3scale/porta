class Provider::Admin::CMS::LayoutsController < Provider::Admin::CMS::TemplatesController

  private

  def templates
    current_account.layouts
  end
end
