module HtmlSelectorsHelper
  def selector_for(scope)
    case scope

    #
    # Page sections
    #
    when 'page content'
      '#content'
    when 'the main menu', :main_menu
       '#tabs'
    when 'the submenu', :submenu
      '#second_nav'
    when 'the subsubmenu'
      '#subsubmenu'  # this is silly
    when 'the application service subsubmenu'
      '.subsubmenu'
    when 'the user widget'
      '#user_widget'
    when 'the footer'
      '#footer'
    when 'the account details box'
      '#account_details'
    when 'the buyers submenu'
      '#submenu'
    when 'the sidetabs', 'the side tabs'
      '#side-tabs'

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
    when 'table header'
      'table thead'

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
