Spring.after_fork do
  FactoryGirl.reload if defined?(FactoryGirl)
  MessageBus.after_fork if defined?(MessageBus)
end
