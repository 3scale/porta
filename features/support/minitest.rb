# https://github.com/cucumber/cucumber/wiki/Using-MiniTest#minitest-5

require 'minitest/unit'

module MinitestWorld
  include Minitest::Assertions
  attr_writer :assertions

  def assertions
    @assertions ||= 0
  end
end

World(MinitestWorld)
