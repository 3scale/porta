# frozen_string_literal: true

# Hack to optimize JSON rendering:
#
# We usually invoke the representer this way:
#
#   wraps_collection :accounts
#   items extend: AccountRepresenter
#
# If the collection has, say 500 records, that call to `items` ends up extending an ActiveRecord model 500 times.
#
# Something like:
#
#  account.extend(AccountRepresenter)
#
# That single call to `items` takes about 3s to complete.
#
# In order to avoid the expensive operation, this hack provides Representable with what it needs in another way.
# Representable needs a collection of items, each of them responding to all record methods and also all representable
# serialization methods.
#
# In order to implement that, the `wraps_representer` method turns the original representer into a wrapper class that:
#
# - Includes all Representable serialization methods
# - Stores a reference to the AR object and delegate all missing methods to it
# - Includes the original representer definition
#
# This way we are providing Representable with a valid collection it can serialize, but we avoid extending 500 items
# because the items belong to class that already included the original representer once during initialization.
class ThreeScale::RepresenterWrapper
  include ThreeScale::JSONRepresenter

  attr_reader :record

  delegate :to_param, to: :record
  delegate_missing_to :record

  # Include the representer's declarations once, when its class is defined.
  def self.wraps_representer(representer)
    include representer
  end

  def self.prepare(record)
    new(record)
  end

  def initialize(record)
    @record = record
  end

  # Override this method used to infer the name of the parent JSON field for each serialized record
  #
  #  "account": {
  #    ..
  #  }
  #
  # The original method assumes we are an AR model extended with Representable methods. This is not the case in this
  # hack, so we need to override it to ensure it takes the name from the AR model.
  def representation_wrap(*args)
    representable_attrs.wrap_for(record, *args)
  end
end
