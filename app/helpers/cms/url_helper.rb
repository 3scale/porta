module CMS
  module UrlHelper
    def cms_draft_url(page)
      url = cms_uri(page)
      url.query += "&cms=draft"
      url.to_s
    end

    def cms_published_url(page)
      url = cms_uri(page)
      url.query += "&cms=published"
      url.to_s
    end

    private

    HARD_WIRED_PATHS = {
      'home' => '/',
      'signup' => '/signup'
    }.freeze

    def cms_uri(page)
      uri = URI.parse(provider_admin_cms_visit_portal_path)
      uri.query = { return_to: page.path ? page.path : HARD_WIRED_PATHS[page.system_name]}.to_query
      uri
    end

  end
end
