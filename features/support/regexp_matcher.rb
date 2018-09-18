RSpec::Matchers.define :have_regexp do |expected|
  match do |actual|
    stripped = actual.delete("\n")
    #OPTIMIZE: call have_text matcher
    stripped.should =~ expected
  end
end

require 'rspec/expectations'
World(RSpec::Matchers)