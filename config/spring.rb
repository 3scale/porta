Spring.after_fork do
  FactoryBot.reload if defined?(FactoryBot)
  MessageBus.after_fork if defined?(MessageBus)
end
