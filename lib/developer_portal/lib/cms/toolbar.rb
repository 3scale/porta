# frozen_string_literal: true

require 'base64'

module CMS::Toolbar
  extend ActiveSupport::Concern

  included do
    prepend_before_action :handle_cms_token
    append_after_action :inject_cms_toolbar, if: :cms_toolbar_enabled?
  end

  def cms_toolbar
    @__cms_toolbar ||= CMS::Toolbar::Renderer.new
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
    response.body = %(
     <html>
       <head>
       </head>
       <body style="margin: 0">
         #{cms_toolbar_with_iframe_html}
       </body>
     </html>
     )
  end

  def cms_toolbar_with_iframe_html
    base = "<base target='_parent' />"
    new_source = response.body.sub(%r{<head(?:.*?)>}i, '\0' + base)

    controller = self

    # Whe on development we want to clear the view cache on every request, this should be automatic, but after
    # https://github.com/rails/rails/pull/35623 and https://github.com/rails/rails/pull/35629 this no longer works
    # for hacked views like the +CMS::Toolbar::View+. So we have to manually clear the cache. Otherwise, we'll have
    # to restart the server after every change in this file.
    ActionView::LookupContext::DetailsKey.clear unless Rails.env.production?

    view = CMS::Toolbar::View.new(lookup_context, cms_toolbar.assigns, controller)
    view._routes = _routes
    view.render 'shared/cms/toolbar',
                :site_account => site_account,
                :original_page_source => new_source
  end
end
