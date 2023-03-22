# frozen_string_literal: true

class Provider::Admin::CMS::PagesController < Provider::Admin::CMS::TemplatesController

  private

  def templates
    current_account.pages
  end

  def allowed_params
    %i[title section_id layout_id path content_type tag_list system_name liquid_enabled handler draft].freeze
  end
end
