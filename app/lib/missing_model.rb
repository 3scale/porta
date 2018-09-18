# frozen_string_literal: true

# Convention: name all missing models following this pattern +MissingModel::Missing<Model>+
class MissingModel
  include ActiveModel::Model
  include GlobalID::Identification

  attr_accessor :id

  def self.find(id)
    new id: id.to_i
  end

  def ==(other)
    id == other.try(:id)
  end

  def self.model_name
    name = self.name.match(/MissingModel::Missing(\w+)$/)[1]
    ::ActiveModel::Name.new(self, nil, name)
  end

  class MissingApplication < MissingModel; end
end
