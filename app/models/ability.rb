# frozen_string_literal: true

# Ability definitions are now split across multiple files, for better maintainability.
#
# To create a new set of permission rules, create a file in config/abilities,
# and define the rules in it like this:
#
#   Ability.define do |user|
#     user.can? :manage, NuclearWeapons if user.has_degree_in_theretical_physics?
#   end
#
class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user = user
    load_rules!
  end

  # This smells of :reek:NilCheck
  def reload!
    user&.reload
    @rules = []
    @rules_index = nil
    load_rules!
    self
  end

  @@rules = []

  def self.define(&block)
    @@rules << block
  end

  def can?(action, subject, *extra_args)
    collection = subject.try(:decorated_collection) || [subject]
    collection.each do |entry|
      model = entry.try(:model) || entry
      return false unless super(action, model, *extra_args)
    end
    true
  end

  private

  def load_rules!
    @@rules.each do |rule|
      instance_exec(user, &rule)
    end
  end
end

Dir["#{Rails.root.join('config', 'abilities')}/**/*.rb"].sort.each { |file| load(file) }
