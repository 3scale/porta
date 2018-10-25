# frozen_string_literal: true

# TODO: Unify this with Logic::Backend::Version in lib/logic/backend.rb

class BackendVersion < ActiveSupport::StringInquirer
  V1 = '1'
  V2 = '2'
  OAUTH = 'oauth'

  VERSIONS = [V1, V2, OAUTH]

  def initialize(value)
    super(value.to_s) if value
  end

  def v1?
    self == V1
  end

  def v2?
    self == V2
  end

  def is?(*versions)
    versions.any?{ |version| self == version.to_s }
  end
end
