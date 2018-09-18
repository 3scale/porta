ActiveRecord::Base.send(:include, ThreeScale::HasMoney) if defined?(ActiveRecord)
ActionController::Base.helper(ThreeScale::MoneyHelper) if defined?(ActionController)
