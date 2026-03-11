# frozen_string_literal: true
# Executable test case for Rails/Active Record STI via association.build
# Run with:  ruby sti_build_exec_test.rb
#
# This file follows the pattern recommended by Rails for "Create an Executable Test Case":
# - Uses bundler/inline
# - Minimal in-memory SQLite schema
# - Inline models + Minitest
# Ref: Rails Guides “Contributing to Ruby on Rails → Create an Executable Test Case”
#      and typical AR issue examples that use this exact style. 

begin
  require "bundler/inline"
rescue LoadError => e
  warn "Bundler 1.10+ required. Please update bundler. (#{e.message})"
  raise
end

# Avoid interference from any local Bundler config/Gemfile in your project/workspace.
ENV["BUNDLE_IGNORE_CONFIG"] = "true"

gemfile(true) do
  source "https://rubygems.org"
  # Pin to Rails 7.1.x line; adjust to your exact patch if you want (e.g., '7.1.3.4').
  gem "activerecord", "7.1.5.2"
  gem "activesupport", "7.1.5.2"
  gem "minitest", "~> 5.20"
  gem "sqlite3", "~> 1.6"
end

require "minitest/autorun"
require "active_record"
require "logger"

# Uncomment for verbose SQL logs while diagnosing:
# ActiveRecord::Base.logger = Logger.new($stdout)

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :zoos, force: true do |t|
    t.string :name
  end

  create_table :animals, force: true do |t|
    t.string  :name
    t.string  :type     # STI column
    t.integer :zoo_id
  end
end

# ==== Models (inline) =========================================================

class Zoo < ActiveRecord::Base
  has_many :animals
end

class Animal < ActiveRecord::Base
  belongs_to :zoo, optional: true
end

class Dog < Animal; end
class Cat < Animal; end

# Optional namespaced subclass to show the sti_name-safe pattern:
module AnimalsNS
  class Fox < ::Animal; end
end

# ==== Tests ===================================================================

class StiBuildExecTest < Minitest::Test
  def test_build_with_type_string_instantiates_subclass
    zoo = Zoo.create!(name: "Edge Zoo")

    rec = zoo.animals.build(type: "Dog", name: "Fido")

    assert_equal Dog, rec.class, "Expected Dog, got #{rec.class} (type=#{rec[:type].inspect})"
    assert_equal "Dog", rec.type
    assert_equal "Fido", rec.name
    assert_equal zoo, rec.zoo
  end

  def test_build_with_sti_name_is_namespace_safe
    zoo = Zoo.create!(name: "Edge Zoo 2")

    # Using sti_name is robust for namespaced classes and store_full_sti_class settings.
    rec = zoo.animals.build(type: AnimalsNS::Fox.sti_name, name: "Tails")

    assert_equal AnimalsNS::Fox, rec.class, "Expected AnimalsNS::Fox, got #{rec.class} (type=#{rec[:type].inspect})"
    assert_equal AnimalsNS::Fox.sti_name, rec.type
    assert_equal "Tails", rec.name
  end

  def test_create_persists_and_reloads_as_subclass
    zoo = Zoo.create!(name: "Edge Zoo 3")
    rec = zoo.animals.create!(type: "Cat", name: "Mittens")

    assert_equal Cat, rec.class
    assert_equal "Cat", rec.type

    reloaded = Animal.find(rec.id)
    assert_equal Cat, reloaded.class, "After reload, expected Cat, got #{reloaded.class}"
  end
end
