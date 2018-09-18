class Provider::Admin::CMS::BuiltinPartialsController < Provider::Admin::CMS::TemplatesController

  def new
    render_error 'Cannot create a new builtin partial.', :status => :not_found
  end

  def create
    render_error 'Cannot create a new builtin partial.', :status => :not_found
  end

  private

  def templates
    current_account.builtin_partials
  end
end
