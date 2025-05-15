# frozen_string_literal: true

module CMS
  class Settings
    DEFAULT_MODE = 'published'

    def initialize(settings, session)
      @settings = settings || ::Settings.new
      @session  = session
    end

    def render_draft_content?
      admin? && cms_session.draft?
    end

    def admin?
      !!@session[:cms_edit]
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

    def cms_session
      ActiveSupport::StringInquirer.new(@session[:cms] || DEFAULT_MODE)
    end
  end
end
