# frozen_string_literal: true

module StatsHelper
  def render_methods_pages(methods, page_size)
    result = ''

    methods.each_slice(page_size).with_index do |page,i|
      style = (i == 0) ? '' : "display:none;"

      result += content_tag( :ul, :class => 'panel', :id => "panel_#{i.to_i}", :style => style) do
        page.inject('') do |memo,method|
          memo + render(:partial => '/stats/method', :object => method)
        end
      end
    end

    result
  end

  # Returns sentence about used timezone with linking to its change.
  #
  def timezone_information(timezone = current_account.timezone)
    name = ActiveSupport::TimeZone.new(timezone).to_s
    name_or_link = if can?(:update, current_account) && current_account.provider?
                     link_to(name, edit_provider_admin_account_path)
                   else
                     name
                   end
    "Using time zone ".html_safe + name_or_link
  end
end
