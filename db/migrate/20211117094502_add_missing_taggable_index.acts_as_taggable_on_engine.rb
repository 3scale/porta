# This migration comes from acts_as_taggable_on_engine (originally 4)
class AddMissingTaggableIndex < ActiveRecord::Migration[5.0]; end
AddMissingTaggableIndex.class_eval do
  # disable_ddl_transaction! if System::Database.postgres?

  def self.up
    rename_index ActsAsTaggableOn.taggings_table, 'index_taggings_on_taggable_id_and_taggable_type_and_context', 'taggings_taggable_context_idx'
  end

  def self.down
    rename_index ActsAsTaggableOn.taggings_table, 'taggings_taggable_context_idx', 'index_taggings_on_taggable_id_and_taggable_type_and_context'
  end
end
