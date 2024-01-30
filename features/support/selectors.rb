# rubocop:disable Style/PerlBackrefs
# frozen_string_literal: true

module HtmlSelectorsHelper
  # :reek:TooManyStatements
  def selector_for(scope) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    case scope

    #
    # Page sections
    #
    when 'page content'
      '#content'
    when 'the main menu', :main_menu
      '#mainmenu'
    when 'the audience dashboard widget', :audience_dashboard_widget
      '#audience'
    when 'the apis dashboard widget', :apis_dashboard_widget
      '.DashboardSection--services'
    when /the secondary nav/,
         /the app menu/
      'nav.pf-c-nav.pf-m-horizontal'
    when 'the user widget'
      '#user_widget'
    when 'the footer'
      '#footer'
    when 'the account details box'
      '#account_details'
    when 'service widget'
      '.service-widget'
    when 'the products widget'
      '#products-widget'
    when 'the latest apps'
      '.pf-c-page__main-section .latest-apps'

    #
    # Invoicing helpers
    #

    when /^(opened|closed) order$/
      text = $1 == 'opened' ? 'open' : $1
      [:xpath, "//tr[td[text() = '#{text}']]"]

    #
    # General helpers
    #
    when /^(the )?table header$/
      'table thead'

    when /^(the )?table body$/
      'table tbody'

    when 'table'
      'table'

    when 'the table'
      '.pf-c-table'

    when 'the toolbar'
      '.pf-c-page__main-section .pf-c-toolbar'

    when 'search form'
      'tr.search'

    when 'the results'
      'table.pf-c-table > tbody'

    when /the body/
      "html > body"

    when 'fancybox', 'colorbox', 'the modal'
      '#cboxContent' # '#fancybox-content'

    when "fancybox header"
      '#cboxContent h2'

    when 'the bulk operations'
      '#bulk-operations'

    when /^section (.*)$/
      [:xpath, "//button[text() = '#{$1}']/following-sibling::section[1]"]

    #
    # Application
    #
    when 'the API Credentials card'
      'div#application_keys'

    when 'the API Credentials\' first application key'
      first('div#application_keys .key')

    when /^application key "(.*)"$/
      find %(#application_keys .key[data-key="#{$1}"])

    when 'the application widget'
      '#applications_widget'

    when 'the change plan card'
      '#change_plan_card'

    when 'the application details'
      '[aria-label="Application details list"], dl.dl-horizontal'

    when 'the referrer filters'
      '#referrer_filters'

    when /the referrer filter "(.*)"/
      find('#referrer_filters tr[id^="referrer_filter_"] td', text: $1)
        .sibling('td')

    #
    # Plans
    #
    when /metric (.*) usage limits/
      find('#metrics_container tr', text: $1).sibling('tr', text: 'Usage Limits')

    when /the features/
      find(:xpath, '//table[@id="features"]/..')

    when /the feature (.*)/
      find('table#features tbody tr', text: $1)

    when 'the plan card'
      '#plan-widget-with-actions'

    #
    # Dev portal
    #
    when 'the pagination'
      'ul.pagination'
    when 'the navigation bar'
      'ul.navbar-nav'
    when 'the application keys'
      '#application_keys'

    else
      raise "Can't find mapping from \"#{scope}\" to a selector.\n" \
            "Add mapping to #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelper)

# rubocop:enable Style/PerlBackrefs
