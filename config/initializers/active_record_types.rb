ActiveSupport.on_load(:active_record) do
  ActiveRecord::Type.register(:policies_config, Attributes::PoliciesConfig)
end
