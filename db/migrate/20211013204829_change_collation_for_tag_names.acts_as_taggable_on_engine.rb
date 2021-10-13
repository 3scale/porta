# This migration comes from acts_as_taggable_on_engine (originally 5)
# This migration is added to circumvent issue #623 and have special characters
# work properly
class ChangeCollationForTagNames < ActiveRecord::Migration[4.2]
  # ignore this migration, our DB is already correct
end
