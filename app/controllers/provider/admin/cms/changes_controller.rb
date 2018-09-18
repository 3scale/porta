class Provider::Admin::CMS::ChangesController < Provider::Admin::CMS::BaseController

  activate_menu :cms, :changes
  sublayout nil

  def index
    @changed = current_account.templates.with_draft
  end


  def publish
    @page ||= templates.find(params[:id])
    @page.publish!
  end

  def publish_all
    @page ||= templates.find_each do |tmpl|
      tmpl.publish!
    end
  end

  def revert
    @page ||= templates.find(params[:id])
    @page.revert!
  end

  private

  def templates
    current_account.templates
  end


end
