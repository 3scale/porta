ActionDispatch::IntegrationTest.class_eval do
  def disable_observers(*observers, &block)
    ActiveRecord::Base.observers.disable(*observers.flatten, &block)
  end
end
