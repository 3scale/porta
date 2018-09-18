class CreateLegalTerms < ActiveRecord::Migration
  def self.up
    create_table :legal_terms do |t|
      t.string :name
      t.string :slug
      t.text :body
      t.integer :version
      t.integer :lock_version, :default => 0
      t.boolean :published, :default => false
      t.boolean :deleted, :default => false
      t.boolean :archived, :default => false
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps
    end

    create_table :legal_term_versions do |t|
      t.string :name
      t.string :slug
      t.text :body
      t.integer :legal_term_id
      t.integer :version
      t.boolean :published, :default => false
      t.boolean :deleted, :default => false
      t.boolean :archived, :default => false
      t.integer :created_by_id
      t.integer :updated_by_id
      t.string :version_comment
      t.timestamps
    end

    #ContentType.create!(:name => "LegalTerm", :group_name => "LegalTerms")
  end

  def self.down
    #ContentType.delete_all(['name = ?', 'LegalTerm'])
    drop_table :legal_term_versions
    drop_table :legal_terms
  end
end
