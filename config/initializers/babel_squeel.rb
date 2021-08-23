ActiveSupport.on_load(:active_record) do
  BabySqueel.configure do |config|
    config.enable_compatibility!
  end
end
