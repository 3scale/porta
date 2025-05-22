class FeaturesPlansIndex< ActiveRecord::Migration[7.0]
  disable_ddl_transaction! if System::Database.postgres?

  def up
    add_index :features_plans, :feature_id, **index_options
  end

  private

  def index_options
    index_options = { unique: false }
    index_options[:algorithm] = :concurrently if System::Database.postgres?
    index_options
  end
end
