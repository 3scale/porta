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
      'forum' => '/forum',
      'signup' => '/signup'
    }.freeze

    def cms_uri(page)
      uri = URI.parse(access_code_url)
      uri.host = page.provider.domain
      uri.query = { return_to: page.path ? page.path : HARD_WIRED_PATHS[page.system_name],
                    access_code: current_account.site_access_code,
                    cms_token: page.provider.settings.cms_token! }.to_query

      if Rails.env.development?
        uri.port = request.port
        uri.host += ".#{ThreeScale.config.dev_gtld}"
      end

      uri
    end

  end
end
