# frozen_string_literal: true

module BreadcrumbsHelper
  def display_active_main_menu
    active_menu == :serviceadmin && @service.present? ? @service.name : active_menu.to_s.humanize
  end

  def display_active_submenu
    text = active_submenu.to_s.humanize
    breadcrumb_unlinkable?(active_submenu) ? text : index_link(text)
  end

  def display_active_sidebar
    text = active_sidebar.to_s.humanize
    breadcrumb_unlinkable?(active_sidebar) ? text : index_link(text)
  end

  private

  def index_link(text)
    link_to text, url_for(action: :index)
  end

  def breadcrumb_unlinkable?(key)
    [:bla_bla].include?(key)
  end
end
