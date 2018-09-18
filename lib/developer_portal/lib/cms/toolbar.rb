require 'base64'

module CMS::Toolbar
  extend ActiveSupport::Concern

  include ThreeScale::DevDomain if ThreeScale::DevDomain.enabled?

  included do
    prepend_before_action :handle_cms_token
    append_after_action :inject_cms_toolbar, if: :cms_toolbar_enabled?
  end

  def cms_toolbar
    @__cms_toolbar ||= CMS::Toolbar::Renderer.new
  end

  class Renderer
    attr_reader :page
    attr_writer :layout

    def initialize
      @templates = []
      @liquids = []
    end

    def liquid(template)
      @liquids << template
    end

    def rendered(view)
      @templates << view
    end

    def main_page=(page)
      if @page
        rendered(page)
      else
        @page = page
      end
    end

    def layout
      @layout or @page.try(:layout)
    end

    def assigns
      liquids = @liquids.try(:map){ |t| t.registers[:file_system].try(:history) } || []
      templates = [ page, layout ] + liquids + @templates

      { page: page, templates: templates.flatten.compact.uniq }
    end
  end

  protected

  def handle_cms_token
    token = params.delete(:cms_token)

    if cms.valid_token?(token)
      session[:cms_token] = token
      Rails.logger.info "CMS edit mode enabled"
    elsif token
      session[:cms_token] = nil
      session[:cms] = nil
      Rails.logger.info "Invalid CMS edit mode token."
    end

    if (mode = params.delete(:cms).presence)
      session[:cms] = mode
    end
  end

  private

  def cms_toolbar_enabled?
    return false if @_exception_handled

    is_cms_domain = site_account.provider? && !site_account.master? # => buyer domain
    is_html_content = response.content_type.nil? || response.content_type == 'text/html' #=> only for html content type

    return false unless is_cms_domain
    return false unless is_html_content
    return false if request.xhr?
    return false unless cms.admin?

    return true
  end

  # TODO: do not overwrite existing <base>
  def inject_cms_toolbar
    response.body = %{
     <html>
       <head>
       </head>
       <body style="margin: 0">
         #{cms_toolbar_with_iframe_html}
       </body>
     </html>
     }
  end

  def cms_toolbar_with_iframe_html
    base = "<base target='_parent' />"
    new_source = response.body.sub(%r{<head(?:.*?)>}i, '\0' + base)

    controller = self

    view = View.new(lookup_context, cms_toolbar.assigns, controller, [:html])
    view._routes = _routes
    view.render 'shared/cms/toolbar',
                :site_account => site_account,
                :original_page_source => new_source
  end

  class View < ActionView::Base
    include ::Rails.application.routes.url_helpers
    include ::DeveloperPortal::CMS::ToolbarHelper
  end
end
