# frozen_string_literals: true

module Indexer
  DEFAULT_OPTIONS = { verbose: false, wait_until_finished: true }.freeze
  MAX_WAITING_CYCLES = 20
  SLEEP_TIME_BETWEEN_CYCLES = 0.25

  module_function

  def run(&block)
    ThinkingSphinx::Test.run(&block)
  end

  def run_after_index(opts = {}, &block)
    run do
      index(opts)
      block.call
    end
  end

  def index(opts = {})
    options = opts.reverse_merge DEFAULT_OPTIONS

    wait = options.delete(:wait_until_finished)

    ThinkingSphinx::Test.config
    ThinkingSphinx::Test.index options

    wait_until_index_finished(options[:verbose]) if wait
  end

  def index_finished?
    # From https://freelancing-gods.com/thinking-sphinx/v3/testing.html
    Dir[Rails.root.join(ThinkingSphinx::Test.config.indices_location, '*.{new,tmp}*')].empty?
  end

  def wait_until_index_finished(verbose = false)
    count = 0
    until index_finished? || count >= MAX_WAITING_CYCLES
      puts 'sphinx index not finished yet...' if verbose
      count += 1
      sleep SLEEP_TIME_BETWEEN_CYCLES
    end

    puts 'reached maximum number of waiting cycles' if count >= MAX_WAITING_CYCLES && verbose
  end
end
