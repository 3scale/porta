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
    token = validate_and_extract_cms_token

    if cms.valid_token?(token)
      session[:cms_token] = token
      Rails.logger.info "CMS edit mode enabled for portal #{site_account.external_domain}"
    elsif token
      session[:cms_token] = nil
      session[:cms] = nil
      Rails.logger.info "Invalid CMS edit mode signature for portal #{site_account.external_domain}"
    end

    if (mode = params.delete(:cms).presence)
      session[:cms] = mode
    end
  end

  def draft?
    session[:cms] == 'draft'
  end

  private

  def validate_and_extract_cms_token
    signature = params.delete(:signature)
    return signature if signature.blank?

    expires_at = Time.at(params.delete(:expires_at).to_i).utc
    raise ActiveSupport::MessageVerifier::InvalidSignature unless expires_at > Time.now.utc

    cms_token = site_account.settings.cms_token!
    valid_signature = signature == CMS::Signature.generate(cms_token, expires_at)

    raise ActiveSupport::MessageVerifier::InvalidSignature unless valid_signature

    # We don't need the signature after processing, better remove it to avoid resending it with future redirections
    request.query_parameters.delete(:expires_at)
    request.query_parameters.delete(:signature)

    cms_token
  rescue StandardError
    # In the case the signature is invalid or any other problem, I don't think we have to bother the client and
    # BugSnag with an exception. Better return an empty token which means "Disable CMS edit mode (hide toolbar)"
    flash[:error] = 'Disabling CMS edit mode due to an invalid or expired signature'
    ''
  end

  def cms_toolbar_enabled?
    return false if @_exception_handled

    is_cms_domain = site_account.provider? && !site_account.master? # => buyer domain
    is_html_content = response.media_type.nil? || response.media_type == 'text/html' #=> only for html content type

    return false unless is_cms_domain
    return false unless is_html_content
    return false if request.xhr?
    return false unless cms.admin?

    return true
  end

  # TODO: do not overwrite existing <base>
  def inject_cms_toolbar
    response.body = %(
     <html class="pf-theme-dark">
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

    # When on development we want to clear the view cache on every request, this should be automatic, but after
    # https://github.com/rails/rails/pull/35623 and https://github.com/rails/rails/pull/35629 this no longer works
    # for hacked views like the +CMS::Toolbar::View+. So we have to manually clear the cache. Otherwise, we'll have
    # to restart the server after every change in this file.
    ActionView::LookupContext::DetailsKey.clear unless Rails.env.production?

    view = CMS::Toolbar::View.new(lookup_context, cms_toolbar.assigns, controller)
    view._routes = _routes
    view.render 'shared/cms/toolbar',
                :hidden => draft? && cookies['cms-toolbar-state'] == 'hidden',
                :draft => draft?,
                :site_account => site_account,
                :original_page_source => new_source
  end
end
