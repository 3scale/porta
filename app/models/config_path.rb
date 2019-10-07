# frozen_string_literal: true

class ConfigPath
  EMPTY_PATH = '/'

  attr_reader :path

  def initialize(value)
    self.path = value
  end

  def to_regex
    return '/.*' if empty?

    "#{path}/.*|#{path}/?"
  end

  def empty?
    path == EMPTY_PATH
  end

  private

  def path=(value)
    @path = EMPTY_PATH + StringUtils::StripSlash.strip_slash(value)
  end
end
