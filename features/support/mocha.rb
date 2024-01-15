require "mocha/api"

World(Mocha::API)

Around do |scenario, block|
  begin
    mocha_setup
    block.call
    mocha_verify
  ensure
    mocha_teardown
  end
end
