# frozen_string_literal: true

Then /debug/ do
  require 'pry'
  binding.pry
end
