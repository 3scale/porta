# frozen_string_literal: true

module BreadcrumbsHelper
  def display_active_main_menu
    active_menu == :serviceadmin && @service.present? ? @service.name : active_menu.to_s.humanize
  end

  def display_active_submenu
    active_submenu.to_s.humanize
  end

  def display_active_sidebar
    active_sidebar.to_s.humanize
  end
end
