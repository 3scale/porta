# frozen_string_literal: true

class ProgressCounter
  attr_reader :total, :index

  class << self
    # This logger just prints out a message to STDOUT, with new line before and after.
    # New line before is to make progress log look better
    def stdout_logger
      log = ActiveSupport::Logger.new($stdout)
      log.formatter = ->(_, _, _, msg) { "\n#{msg.is_a?(String) ? msg : msg.inspect}\n" }
      log
    end
  end

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
