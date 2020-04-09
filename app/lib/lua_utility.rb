# frozen_string_literal: true

module LuaUtility
  MAGIC_CHARACTERS = %w@( ) . % + - * ? [ ^ $@.freeze
  ESCAPE_CHARACTER = '%'

  module_function

  def escape(string)
    string.gsub(/./) do |char|
      MAGIC_CHARACTERS.include?(char) ? [ESCAPE_CHARACTER, char].join : char
    end
  end
end
