# frozen_string_literal: true

module CMSHelper
  def cms_buttons_click(dropdown, option)
    find("#cms-#{dropdown}-button button.dropdown-toggle").click unless has_css?("#cms-#{dropdown}-button.pf-m-expanded", wait: 1)

    within("#cms-#{dropdown}-button ul.pf-c-dropdown__menu") do
      click_link_or_button option
    end
  end
end

World(CMSHelper)
