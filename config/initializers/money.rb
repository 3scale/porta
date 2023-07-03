ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, ThreeScale::HasMoney)
end

Rails.application.config.to_prepare do
  ActionController::Base.helper(ThreeScale::MoneyHelper) if defined?(ActionController)
end
