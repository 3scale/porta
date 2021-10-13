# This migration comes from acts_as_taggable_on_engine (originally 6)
if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class AddMissingIndexesOnTaggings < ActiveRecord::Migration[4.2]; end
else
  class AddMissingIndexesOnTaggings < ActiveRecord::Migration; end
end
AddMissingIndexesOnTaggings.class_eval do
  disable_ddl_transaction! if System::Database.postgres?

  def change
    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}

    # disabled https://github.com/mbleigh/acts-as-taggable-on/issues/1052
    # add_index ActsAsTaggableOn.taggings_table, :tag_id, index_options
    # add_index ActsAsTaggableOn.taggings_table, :taggable_id, index_options
    add_index ActsAsTaggableOn.taggings_table, :taggable_type, index_options
    # disabled https://github.com/mbleigh/acts-as-taggable-on/issues/1052
    # add_index ActsAsTaggableOn.taggings_table, :tagger_id, index_options
    add_index ActsAsTaggableOn.taggings_table, :context, index_options

    add_index ActsAsTaggableOn.taggings_table, [:tagger_id, :tagger_type], index_options

    safety_assured do
      add_index ActsAsTaggableOn.taggings_table, [:taggable_id, :taggable_type, :tagger_id, :context], name: 'taggings_idy', **index_options
    end
  end
end
