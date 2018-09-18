Hash.send(:include, ThreeScale::HashHacks)

ActiveSupport::OrderedHash.send(:include, ThreeScale::HashHacks)
ActiveSupport::OrderedHash.send(:include, ThreeScale::OrderedHashHacks)
