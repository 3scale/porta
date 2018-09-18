class Provider::Admin::CMS::PagesController < Provider::Admin::CMS::TemplatesController

  private

  def templates
    current_account.pages
  end

  # TODO: is there better way to do it?
  #
  def template_params
    params.require(:cms_template).permit(:title, :section_id, :layout_id, :path,
      :content_type, :tag_list, :system_name, :liquid_enabled, :handler, :draft).tap do |params|

      section_id = params.delete(:section_id).presence
      layout_id  = params.delete(:layout_id).presence

      params[:section] = current_account.sections.find(section_id) if section_id
      # We need to handle the case when the layout_id is purposely nil
      params[:layout] = layout_id && current_account.layouts.find(layout_id)
    end
  end
end
