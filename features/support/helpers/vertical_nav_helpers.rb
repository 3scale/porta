# frozen_string_literal: true

module VerticalNavHelpers
  def select_vertical_nav_section(name)
    within(css_selector) do
      open_collapsed_section_for(name) if has_no_css?('.pf-c-nav__item', text: name)
      find('.pf-c-nav__subnav .pf-c-nav__item', text: name).click
    end
  end

  private

  def open_collapsed_section_for(name)
    find('.pf-c-nav__list > .pf-c-nav__item', text: name, visible: :all).click
  end

  def css_selector
    '#vertical-nav-wrapper'
  end
end

World(VerticalNavHelpers)
