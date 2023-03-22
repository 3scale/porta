# frozen_string_literal: true

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

  def allowed_params
    %i[draft layout_id].freeze
  end
end
