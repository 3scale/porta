# rubocop:disable Style/PerlBackrefs
# frozen_string_literal: true

module HtmlSelectorsHelper
  # :reek:TooManyStatements
  def selector_for(scope) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    case scope

    #
    # Page sections
    #
    when /^the main menu$/
      '#mainmenu'

    when /^the main menu's section (.*)$/
      find('#mainmenu button', text: $1).sibling('.pf-c-nav__subnav', visible: false)

    when /the secondary nav/
      'nav.pf-c-nav.pf-m-horizontal'

    when /the modal/
      '#cboxContent, .pf-c-modal-box' # '#fancybox-content'

    #
    # Dashboard
    #
    when /the audience dashboard widget/
      '#audience'
    when /the apis dashboard widget/
      '#apis'
    when /the products widget/
      '#products-widget'
    when /the backends widget/
      '#backends-widget'

    #
    # Tables
    #
    when /^the table header$/
      'table thead'

    when /^the table body$/
      'table tbody'

    when /the table/
      '.pf-c-table'

    when /the toolbar/
      '.pf-c-page__main-section .pf-c-toolbar'

    when /the search form/
      'tr.search'

    when /the bulk operations/ # Legacy bulk operations card, not the toolbar dropdown
      '.pf-c-card#bulk-operations'

    when /the access tokens table/
      '.pf-c-table[aria-label="Access tokens table"]'

    #
    # Product
    #
    when /deployment options/
      '#service_deployment_option_input'

    when /authentication methods/
      '#service_proxy_authentication_method_input'

    when /the hourly usage limit for metric "(.*)" on application plan "(.*)"/
      plan = ApplicationPlan.find_by!(name: $2)
      metric = plan.metrics.find_by!(system_name: $1)
      usage_limit = metric.usage_limits.find_by!(period: 'hour')
      "##{dom_id(usage_limit)}"

    #
    # Application
    #
    when /the API Credentials card/
      'div#application_keys'

    when /^application key "(.*)"$/
      find %(#application_keys .key[data-key="#{$1}"])

    when /the application widget/
      '#applications_widget'

    when /the change plan card/
      '#change_plan_card'

    when /the current utilization card/
      '#application-utilization'

    when /the application details/
      '[aria-label="Application details list"], dl.dl-horizontal'

    when /the account details card/
      '[aria-label="Account details"], div.dashboard_card'

    when /the referrer filters/
      '#referrer_filters'

    when /the referrer filter "(.*)"/
      find('#referrer_filters tr[id^="referrer_filter_"] td', text: $1)
        .sibling('td')

    #
    # Plans
    #
    when /metric "(.*)" usage limits/
      find('#metrics_container tr', text: $1).sibling('tr', text: 'Usage Limits')

    when /the features/
      find(:xpath, '//table[@id="features"]/..')

    when /feature "(.*)"/
      find('table#features tbody tr', text: $1)

    when /the plan card/
      '#plan-widget-with-actions'

    #
    # Users
    #
    when /user "(.*)"/
      "#user_#{User.find_by(username: $1).id}"

    #
    # Finance
    #
    when 'the line items card'
      '.pf-c-card#line_items'

    when 'the transactions card'
      '.pf-c-card .pf-c-table[aria-label="Transactions table"]'

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
