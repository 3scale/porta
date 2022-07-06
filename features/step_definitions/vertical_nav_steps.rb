# frozen_string_literal: true

def subsection_from_vertical_nav?(section, subsection)
  within find(:css, '#vertical-nav-wrapper') do
    anchor = find(:css, 'a.pf-c-nav__link', text: section)
    click_on(section) unless anchor[:'aria-expanded'] == 'true'
    return has_content?(subsection)
  end
end

def section_from_vertical_nav?(section)
  within find(:css, '#vertical-nav-wrapper') do
    return has_content?(section)
  end
end
