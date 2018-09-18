class Session
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :username, :password, :remember_me

  # Just to avoid 'Object#id will be deprecated;' warnings
  def id
    nil
  end

  def persisted?
    false
  end
end
