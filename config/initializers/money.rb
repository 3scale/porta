require 'three_scale/money_conversions'

Rails.application.config.to_prepare do
  ActionController::Base.helper(ThreeScale::MoneyHelper)

  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.include ThreeScale::HasMoney
  end
end
