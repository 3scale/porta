# frozen_string_literal: true

class Provider::Admin::CMS::LayoutsController < Provider::Admin::CMS::TemplatesController

  private

  def templates
    current_account.layouts
  end

  def allowed_params
    %i[system_name draft title liquid_enabled].freeze
  end
end
