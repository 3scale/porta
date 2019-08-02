module CMS
  class Settings
    DEFAULT_MODE = 'published'.freeze

    def initialize(settings, session)
      @settings = settings
      @session  = session
    end

    def render_draft_content?
      admin? && cms_session.draft?
    end

    def admin?
      valid_token?(user_cms_token)
    end

    def valid_token?(token)
      token.present? && token == @settings.cms_token
    end

    def escape_html?
      if render_draft_content?
        @settings.cms_escape_draft_html?
      else
        @settings.cms_escape_published_html?
      end
    end

    def content_for_store
      @content_for_store ||= CMS::ContentForStore.new
    end

    private

      def user_cms_token
        @session[:cms_token]
      end

      def cms_session
        ActiveSupport::StringInquirer.new(@session[:cms] || DEFAULT_MODE)
      end
  end
end
