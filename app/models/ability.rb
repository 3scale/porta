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

  def initialize(user)
    @user = user
    load_rules!
  end

  def reload!
    @user.try!(:reload)
    @rules = []
    load_rules!
    self
  end

  @@rules = []

  def self.define(&block)
    @@rules << block
  end

  private

  def load_rules!
    @@rules.each do |rule|
      self.instance_exec(@user, &rule)
    end
  end
end

Dir["#{Rails.root.join('config', 'abilities')}/**/*.rb"].sort.each { |file| load(file) }
