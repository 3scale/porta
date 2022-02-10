# frozen_string_literal: true

Then "I should be able to start following a quick start from a gallery" do
  within '#quick-start-catalog-page-wrapper .pfext-quick-start-catalog__gallery' do
    quick_starts = find_all('.pfext-quick-start-catalog__gallery-item')
    assert_not quick_starts.empty?
    expect(page).not_to have_selector(quick_start_panel)

    quick_starts.first.click
  end

  assert find(quick_start_panel)
end

Given "I am following a quick start" do
  # This depends on the actual quick starts stored in app/javascript/src/QuickStarts/templates
  @quickstart_id = 'getting-started-with-quick-starts'
  page.execute_script "window.localStorage.setItem('quickstartId', '\"#{@quickstart_id}\"')"
  page.execute_script "window.localStorage.setItem('quickstarts', '{\"#{@quickstart_id}\":{\"status\":\"In Progress\",\"taskNumber\":0,\"taskStatus0\":\"Visited\",\"taskStatus1\":\"Initial\"}}')"
  Capybara.refresh
end

When "I go anywhere else" do
  visit provider_admin_dashboard_path
end

Then "I will still be able to see the quick start" do
  assert find('.pf-c-drawer.pf-m-expanded')
  assert find(quick_start_panel)
end

Then "I should be able to close it without losing any progress" do
  assert_not_empty JSON.parse(local_storage('quickstartId'))
  progress = local_storage('quickstarts')

  within quick_start_panel do
    find('[data-testid="qs-drawer-close"] button').click
  end

  within '.pfext-quick-start-drawer__modal' do
    assert find('header', text: 'Leave quick start?')
    click_on 'Leave'
  end

  assert_empty JSON.parse(local_storage('quickstartId'))
  assert_equal progress, local_storage('quickstarts')
end

Given "I have finished a quick start" do
  # This depends on the actual quick starts stored in app/javascript/src/QuickStarts/templates
  @quickstart_id = 'getting-started-with-quick-starts'
  page.execute_script "window.localStorage.setItem('quickstartId', '\"\"')"
  page.execute_script "window.localStorage.setItem('quickstarts', '{\"#{@quickstart_id}\":{\"status\":\"Complete\",\"taskNumber\":2,\"taskStatus0\":\"Review\",\"taskStatus1\":\"Review\"}}')"
  Capybara.refresh
end

Then "I should be able to restart its progress" do
  visit provider_admin_quick_starts_path

  find("[data-test='tile #{@quickstart_id}']").click

  find "[data-testid='qs-drawer-#{@quickstart_id.underscore.camelize(:lower)}']"
  assert_equal 'Restart', find('[data-testid="qs-drawer-side-note-action"]').text
end

def quick_start_panel
  '.pf-c-drawer__panel[data-test="quickstart drawer"]'
end
