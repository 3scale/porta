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
    when 'the secondary nav'
      'nav.pf-c-nav.pf-m-horizontal'
    when 'the user widget'
      '#user_widget'
    when 'the footer'
      '#footer'
    when 'the account details box'
      '#account_details'
    when 'service widget'
      '.service-widget'

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
      bulk_operations_selector

    when /^section (.*)$/
      [:xpath, "//button[text() = '#{$1}']/following-sibling::section[1]"]

    #
    # Application
    #
    when 'the API Credentials card'
      'div#application_keys'

    else
      raise "Can't find mapping from \"#{scope}\" to a selector.\n" \
            "Add mapping to #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelper)

# rubocop:enable Style/PerlBackrefs
