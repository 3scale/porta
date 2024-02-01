# rubocop:disable Style/PerlBackrefs
# frozen_string_literal: true

module HtmlSelectorsHelper
  # :reek:TooManyStatements
  def selector_for(scope) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    case scope

    #
    # Page sections
    #
    when /the main menu/
      '#mainmenu'

    when /^the main manu's section (.*)$/
      find('#mainmenu button', text: $1).sibling('.pf-c-nav__subnav')

    when /the apis dashboard widget/
      '.DashboardSection--services'

    when /the secondary nav/
      'nav.pf-c-nav.pf-m-horizontal'

    when /the modal/
      '#cboxContent' # '#fancybox-content'

    #
    # Dashboard
    #
    when /the audience dashboard widget/
      '#audience'
    when /the products widget/
      '#products-widget'

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

    when /the bulk operations/
      '#bulk-operations'

    #
    # Product
    #
    when /deployment options/
      '#service_deployment_option_input'

    when /authentication methods/
      '#service_proxy_authentication_method_input'

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
