require 'three_scale/money_conversions'
require 'three_scale/has_money'

ActiveSupport.on_load(:active_record) do
  include ThreeScale::HasMoney
end

Rails.application.config.to_prepare do
  ActionController::Base.helper(ThreeScale::MoneyHelper)
end
