class Provider::Admin::CMS::BuiltinPagesController < Provider::Admin::CMS::TemplatesController

  def new
    render_error 'Cannot create a new builtin page.', :status => :not_found
  end

  def create
    render_error 'Cannot create a new builtin page.', :status => :not_found
  end

  private

  def templates
    current_account.builtin_pages
  end

  def template_params
    params.require(:cms_template).permit(:draft, :layout_id).tap do |params|

      layout_id = params.delete(:layout_id).presence

      params[:layout] = current_account.layouts.find(layout_id) if layout_id
    end
  end
end
