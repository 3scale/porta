class DeveloperPortal::CMS::NewContentController < DeveloperPortal::BaseController

  skip_before_action :login_required

  before_action :ensure_can_view_content, :if => :check_permissions?

  # Redirect to credit card details only for '/' and '/docs' path
  # Other pages will be normally accessible
  skip_before_action :finish_signup_for_paid_plan, unless: :protected_content_from_new_paid_signup

  prepend_before_action :redirect_to_dashboard

  # There is no way how a CMS get action could lead to CSRF.
  # Rails now checks for CSRF token when serving JS and our CMS
  # serves JS, so would have to pass this token. So just disabling this
  # so normal browsing keeps working and loading JS as <script> tag.
  skip_before_action :verify_authenticity_token

  # that's because of css, png.. files
  skip_before_action :verify_requested_format!

  activate_menu :portal

  PROTECTED_CONTENT_FROM_PAID_SIGNUP = Set.new(['/', '/docs']).freeze
  def show
    return unless ensure_buyer_domain

    case
    when redirect # redirect
      head(:moved_permanently, :location => redirect.target)

    when file # render file
      attachment = file.attachment

      if file.redirect? # redirect to amazon
        head(:found, :location => file.url(expires: 3600).to_s, :content_type => attachment.content_type, :cache_control => "public, max-age=3600")

      else # stream stored data
        send_file Paperclip.io_adapters.for(attachment).path,
                  :content_type => attachment.content_type,
                  :disposition => file.disposition.to_s,
                  :filename => attachment.original_filename
      end
    else # render page
      # HACK: remove this when vendor/developer_portal is a real Rails::Engine
      append_view_path Liquid::Template::FallbackResolver.new
      append_view_path Liquid::Template::FallbackResolverNoPrefix.new


      page = find_page!

      assign_drops :page => Liquid::Drops::Page.new(page),
      :page_title => page.title # Liquid::Drops::Deprecated.new(page_title)

      # CMS::Page#mime_type is parsed and valid Mime::Type
      # in case it can't be parsed (nil, something invalid) returns 'text/html'
      render :layout => false, :content_type => page.mime_type, :text => renderer.content
    end
  end

  private

  def protected_content_from_new_paid_signup
    PROTECTED_CONTENT_FROM_PAID_SIGNUP.include?(request.path)
  end

  def redirect_to_dashboard
    # ignore buyer domains
    return if Account.providers.find_by_domain(request.host)

    if not current_account
      redirect_to(provider_login_path)
      # root path '/'
    elsif current_account.provider? && (not params[:path])
      redirect_to(provider_admin_dashboard_path)
    end
  end

  def renderer
    request.env['cms.renderer'] ||= CMS::Renderer.new(page,
                                                      :draft => cms.render_draft_content?,
                                                      :assigns => assigns_for_liquify ) do |template|
      prepare_liquid_template(template)
      cms_toolbar.main_page = page
    end
  end

  def path
    CMS::Page.path(params[:path], params[:format])
  end

  def content
    file or page
  end

  def page
    @page ||= site_account.pages.find_by_path!(path)
  end

  alias find_page! page

  def file
    @file ||= site_account.files.find_by_path(path)
  end

  def redirect
    @redirect ||= site_account.redirects.find_by_source(path)
  end

  protected

  def check_permissions?
    not redirect and not cms.render_draft_content?
  end

  def ensure_can_view_content
    raise ActiveRecord::RecordNotFound unless content.accessible_by?(current_account) #=> this will be handled by cms and transformed into a proper 404
  end
end
