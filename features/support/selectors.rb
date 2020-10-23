# frozen_string_literal: true

module HtmlSelectorsHelper
  def selector_for(scope)
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
    when 'the apis dashboard products widget'
      '#products-widget'
    when 'the apis dashboard backends widget'
      '#backends-widget'
    # TODO: there is no first api widget anymore, clean this up
    when 'the first api dashboard widget'
      '.DashboardSection--services'
    when 'the subsubmenu'
      '.subsubmenu'
    when 'the user widget'
      '#user_widget'
    when 'the footer'
      '#footer'
    when 'the account details box'
      '#account_details'
    when 'notification settings'
      'table.notification-settings tbody'
    when 'service widget'
      '.service-widget'

    #
    # Invoicing helpers
    #

    when /^(opened|closed) order$/
      text = case $1.to_sym
             when :opened
        'open'
             else
        $1
      end
      [:xpath, "//tr[td[text() = '#{text}']]"]

    when /the row for ([^:"]+) active docs/
      [:xpath, "//tr[td[text() = '#{$1}']]"]

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
      'form.search'

    when 'the results'
      'table.data > tbody'

    when /the body/
      "html > body"

    when 'fancybox', 'colorbox'
      '#cboxContent' # '#fancybox-content'

    when "fancybox header"
      '#cboxContent h2'

    else
      raise "Can't find mapping from \"#{scope}\" to a selector.\n" +
        "Add mapping to #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelper)
