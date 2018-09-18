# we always want benchmarks as profiling fails on this huge monster app
ARGV.replace(ARGV + %w{--benchmark})

require 'test_helper'

require 'action_dispatch/testing/performance_test'

# silly minitest test/unit stub fails on --benchmark optio
ARGV.replace(ARGV - %w{--benchmark})

require 'rails/performance_test_help'

__END__

# enable tail call optimalization
RubyVM::InstructionSequence.compile_option = {
  :tailcall_optimization => true,
  :trace_instruction => false
}
