module ThreeScale
  module MoneyHelper
    # Currency the prices should be displayed in. If price has different
    # currency than this one, it will be shown in original currency as well as
    # converted to this one.
    #
    # == Example
    #
    # You can use this in before_action like this:
    #
    #   class ApplicationController < ActionController::Base
    #     before_action :set_display_currency
    #
    #     # ...
    #
    #     private
    #
    #     def set_display_currency
    #       ThreeScale::MoneyHelper.display_currency = current_user.currency
    #     end
    #   end
    mattr_accessor :display_currency

    # Format price with currency
    #
    # == Arguments
    # +money+::   price to be displayed
    #
    # == Returns
    # String with formatted price.
    #
    def price_tag(money, options = {})
      format_money(money, {:html => true}.merge(options))
    end

    def format_money(money, options)
      new_options = {
        :format => options[:html] ? "%u&nbsp;%n".html_safe : "%u %n",
        :negative_format => options[:html] ? "%u&nbsp;-%n".html_safe : "%u -%n",
        :unit => money.currency.presence || ''
      }
      new_options.merge! options.slice(:precision)

      number_to_currency(money.amount, new_options)
    end
  end
end
