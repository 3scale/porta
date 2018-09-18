module DeveloperPortal::CMS::ToolbarHelper

  THEMES = [
      [ 'None', '', '', ''],
      [ 'Yellow Message', '#DD9600', 'rgba(223, 155, 11, 0.98)', '/images/notes.jpg'],
      [ 'Green Dust', '#7F8F00', 'rgba(131, 146, 16, 0.98)', '/images/plant.jpg'],
      [ 'Grey Ice', '#898989', 'rgba(140, 140, 140, 0.98)', '/images/mouse.jpg'],
  ].freeze

  include ::IconHelper

  def site_account
    controller.send(:site_account)
  end

  def cms_mode
    @_cms_mode ||= ActiveSupport::StringInquirer.new(session[:cms] || CMS::Settings::DEFAULT_MODE)
  end

  def theme_options
    THEMES.map do |name, bgcolor_solid, bgcolor, img_url|
      snippet = <<-STYLE.strip_heredoc if bgcolor.present?
        body {
          background-color: #{bgcolor_solid}; /* fallback */
          background-color: #{bgcolor};
        }

        .page-header {
          background-image: url(#{img_url});
        }
      STYLE

      content_tag(:option, name, data: { snippet: snippet }, value: name)
    end.join.html_safe
  end

  def template_url(template)
    if template.new_record?
      # This should not happen when we have all templates in db
    else
      opts = { host: site_account.self_domain }
      opts = ThreeScale::DevDomain::URL.options(request, opts) if ThreeScale::DevDomain.enabled?

      # main_app is not available in the engine
      routes = Rails.application.routes
      main_app = ActionDispatch::Routing::RoutesProxy.new(routes, self, routes.url_helpers)

      polymorphic_url([ main_app, :edit, :provider, :admin, template ], opts)
    end
  end
end
