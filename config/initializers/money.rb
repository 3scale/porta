require 'three_scale/money_conversions'

Rails.application.config.after_initialize do
  ActionController::Base.helper(ThreeScale::MoneyHelper)

  ActiveRecord::Base.include ThreeScale::HasMoney
end
