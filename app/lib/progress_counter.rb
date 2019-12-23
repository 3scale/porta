# frozen_string_literal: true

class ProgressCounter
  attr_reader :total, :index

  def initialize(total)
    @index = 0
    @total = total
    spinner = Enumerator.new do |e|
      loop do
        e.yield '|'
        e.yield '/'
        e.yield '-'
        e.yield '\\'
      end
    end
    @progress = -> do
      printf("\r %d / %d completed %s", index, total, spinner.next)
    end
  end

  def call(increment: 1)
    yield self if block_given?
    @index += increment
    @progress.call
  end
end
