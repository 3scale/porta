# This migration comes from acts_as_taggable_on_engine (originally 2)
if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class AddMissingUniqueIndices < ActiveRecord::Migration[4.2]; end
else
  class AddMissingUniqueIndices < ActiveRecord::Migration; end
end
AddMissingUniqueIndices.class_eval do
  disable_ddl_transaction! if System::Database.postgres?

  def self.up
    add_index ActsAsTaggableOn.tags_table, [:name, :tenant_id], unique: true, name: 'index_tags_on_name', **index_options

    remove_index ActsAsTaggableOn.taggings_table, :tag_id if index_exists?(ActsAsTaggableOn.taggings_table, :tag_id)
    remove_index ActsAsTaggableOn.taggings_table, name: 'taggings_taggable_context_idx' if index_exists?(ActsAsTaggableOn.taggings_table, :taggings_taggable_context_idx)
    add_index ActsAsTaggableOn.taggings_table,
              [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
              unique: true, name: 'taggings_idx', **index_options
  end

  def self.down
    remove_index ActsAsTaggableOn.tags_table, name: 'index_tags_on_name'

    remove_index ActsAsTaggableOn.taggings_table, name: 'taggings_idx'

    add_index ActsAsTaggableOn.taggings_table, :tag_id, **index_options unless index_exists?(ActsAsTaggableOn.taggings_table, :tag_id)
    # add_index ActsAsTaggableOn.taggings_table, [:taggable_id, :taggable_type, :context], name: 'taggings_taggable_context_idx', **index_options
  end

  def index_options
    System::Database.postgres? ? { algorithm: :concurrently } : {}
  end
 end
