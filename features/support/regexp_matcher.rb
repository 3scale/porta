# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :have_regexp do |expected|
  match do |actual|
    stripped = actual.delete("\n")
    #OPTIMIZE: call have_text matcher
    stripped.should =~ expected
  end
end

World(RSpec::Matchers)
