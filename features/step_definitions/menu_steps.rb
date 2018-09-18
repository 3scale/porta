# The table should look like this:
#
#    | Applications |              |
#    | -            | All          |
#    | -            | Live         |
#    |              |              |
#    | Settings     |              |
#    | -            | Applications |
#
# Blank rows and cells starting with '-' are ignored.
#
# TODO: move to helper
#
Then /^I should have menu$/ do |menu|
  # TODO: use #withing instead of CSS concat (black magic needed
  # though as has_css? fails underneath)
  main_css = selector_for(:main_menu)
  sub_css = selector_for(:submenu)

  menu.rows.each do |current_main, submenu, sidetabs|
    next if current_main.blank? && submenu.blank?

    # TODO: cleanup the assert spaghetti
    if current_main.start_with?('-')
      if submenu.start_with?('-') && sidetabs.present?
        within('#side-tabs') do
          click_link(sidetabs)
          should have_css('.active')
          should have_link(sidetabs)
        end
      else
        assert has_css?("#{sub_css} a",:text => submenu), "Submenu item #{submenu} missing"
        within(sub_css) { click_link(submenu) }

        # second has_css? present for compatibility with Portal submenu
        assert has_css?("#{sub_css} li.active a", :text => submenu) ||
                   has_css?("#{sub_css} li a.active", :text => submenu),
               "Submenu item #{submenu} not highlighted"


        assert has_css?("#{main_css} li.active a", :text => @main_menu),
               "Main menu item #{@main_menu} not selected for #{submenu}"
      end
    else
      @main_menu = current_main

      assert has_css?("#{main_css} a",:text => @main_menu), "Main menu item #{@main_menu} missing"
      within(main_css) { click_link(@main_menu) }
      assert has_css?("#{main_css} li.active > a", :text => @main_menu), "Main menu item #{@main_menu} not highlighted"
    end
  end
end


Then /^I should see the partners submenu$/ do
  step 'I should see the "links" in the submenu:', table(%{
   | link     |
   | Accounts      |
   | Subscriptions |
   | Export  |
  })
end

Then /^I should see menu items$/ do |items|
  items.rows.each do |item|
    within '#second_nav' do
      assert has_css? 'li', :text => item[0]
    end
  end
end

Then /^I choose "(.*?)" in the sidebar$/ do |item|
  within '#side-tabs' do
    click_link(item)
  end
end


Then /^I should see the help menu items$/ do |items|
  items.rows.each do |item|
    within '.PopNavigation--docs ul.PopNavigation-list' do
      assert has_css?('li', :text => item[0])
    end
  end
end



# TODO: replace this with with more generic step?!
Then %r{^I should still be in the "(.+?)"$} do |menu_item|
  assert has_css?('li.active a', :text => menu_item)
end

Then /^I should( not)? see the provider menu$/ do |negative|
  menu = 'ul#tabs li a'
  assert negative ? has_no_css?(menu) : has_css?(menu)
end


Given(/^provider "(.*?)" has xss protection options disabled$/) do |arg1|
  settings = current_account.settings
  settings.cms_escape_draft_html = false
  settings.cms_escape_published_html = false
  settings.save
end
