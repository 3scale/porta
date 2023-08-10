Rails.application.config.to_prepare do
  Hash.send(:include, ThreeScale::HashHacks)

  ActiveSupport::OrderedHash.send(:include, ThreeScale::HashHacks)
end
