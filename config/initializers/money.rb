require 'three_scale/money_conversions'

Rails.application.config.after_initialize do
  ActionController::Base.helper(ThreeScale::MoneyHelper)

  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.include ThreeScale::HasMoney
  end
end
