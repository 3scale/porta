# frozen_string_literal: true

Then "I should be able to start following a quick start from a gallery" do
  within '#quick-start-catalog-page-wrapper .pfext-quick-start-catalog__gallery' do
    quickstarts = find_all('.pfext-quick-start-catalog__gallery-item')
    assert_not quickstarts.empty?
    assert_no_selector(quickstarts_panel)

    quickstarts.first.click
  end

  assert_selector(quickstarts_panel)
end

Given "I am following a quick start" do
  page.execute_script "window.localStorage.setItem('quickstartId', '\"#{test_quickstart_id}\"')"
  page.execute_script "window.localStorage.setItem('quickstarts', '{\"#{test_quickstart_id}\":{\"status\":\"In Progress\",\"taskNumber\":0,\"taskStatus0\":\"Visited\",\"taskStatus1\":\"Initial\"}}')"
  Capybara.refresh
end

When "I go anywhere else" do
  visit provider_admin_dashboard_path
end

Then "I will still be able to see the quick start" do
  assert_selector('.pf-c-drawer.pf-m-expanded')
  assert_selector(quickstarts_panel)
end

Then "I won't be able to see the quick start" do
  assert_no_selector('.pf-c-drawer.pf-m-expanded')
  assert_no_selector(quickstarts_panel)
end

Then "I should be able to close it without losing any progress" do
  assert_not_empty JSON.parse(local_storage('quickstartId'))
  progress = local_storage('quickstarts')

  within quickstarts_panel do
    find('[data-testid="qs-drawer-close"] button').click
  end

  within '.pfext-quick-start-drawer__modal' do
    assert_selector('header', text: 'Leave quick start?')
    click_on 'Leave'
  end

  assert_empty JSON.parse(local_storage('quickstartId'))
  assert_equal progress, local_storage('quickstarts')
end

Given "I have finished a quick start" do
  page.execute_script "window.localStorage.setItem('quickstartId', '\"\"')"
  page.execute_script "window.localStorage.setItem('quickstarts', '{\"#{test_quickstart_id}\":{\"status\":\"Complete\",\"taskNumber\":2,\"taskStatus0\":\"Review\",\"taskStatus1\":\"Review\"}}')"
  Capybara.refresh
end

Then "I should be able to restart its progress" do
  visit provider_admin_quickstarts_path

  find("[data-test='tile #{test_quickstart_id}']").click

  assert_selector '[data-test="quickstart drawer"]'
  assert_selector('[data-testid="qs-drawer-side-note-action"]', text: 'Restart')
end

Then "I {should} be able to go to the quick start catalog from the help menu" do |available|
  open_help_menu
  within help_menu_selector do
    if available
      click_link('Quick starts', visible: true)
      assert_equal provider_admin_quickstarts_path, current_path
    else
      has_no_link?('Quick starts', visible: :all)
    end
  end
end

def test_quickstart_id
  # This depends on the actual quick starts stored in app/javascript/src/QuickStarts/templates
  'getting-started-with-quick-starts'
end

def quickstarts_panel
  '.pf-c-drawer__panel[data-test="quickstart drawer"]'
end
