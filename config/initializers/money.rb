ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, ThreeScale::HasMoney)
end
ActionController::Base.helper(ThreeScale::MoneyHelper) if defined?(ActionController)
