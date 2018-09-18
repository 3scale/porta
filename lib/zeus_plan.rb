require 'zeus/rails'

class NoSmartypants < Zeus::Rails

  def test_helper
    require 'test_helper'
  end

  def spec_helper
    require 'spec_helper'
  end

  def minitest_helper
    require 'minitest_helper'
  end

  def spec(argv=ARGV)
    ::RSpec::Core::Runner.disable_autorun!
    exit ::RSpec::Core::Runner.run(argv)
  end

  class Filter
    attr_reader :methods

    MATCH_ALL = Regexp.new(/./).freeze

    def initialize(methods, filter = nil)
      @methods = methods.map do |method|
        file, line = method.split(':')
        [file, line.to_i] if File.file?(file)
      end.compact
      @pattern = compile_pattern(filter)
    end

    def suites
      ::Minitest::Unit::TestCase.test_suites
    end

    def ===(name)
      klass, test = name.split('#', 2)
      return unless klass && test
      suite = suites.find{ |suite| suite.name == klass } or return
      method = suite.instance_method(test)

      matches_method(method) && matches_pattern(method)
    end

    def filter_methods(method)
      file, start_line = method.source_location
      range = Range.new(start_line, start_line + method.source.lines.size - 1)

      @methods.select { |test,line| line == 0 || file.match(test) && range.cover?(line) }
    end

    def matches_method(method)
      filter_methods(method).any?
    end

    def matches_pattern(method)
      [ method.name, method.original_name ].compact.map(&:to_s).any?(&@pattern)
    end

    def compile_pattern(matcher)
      case matcher
      when /^\/(.*)\/$/ then Regexp.new($1)
      when nil then MATCH_ALL
      when String then matcher.delete(':').tr(' ', '_')
      when ->(m) { m.respond_to?(:match) } then matcher
      else
          raise "Can't use #{matcher} as filter, does not have #match"
      end.method(:match)
    end
  end

  def cucumber_environment
    require 'cucumber/rspec/disable_option_parser'
    require 'cucumber/cli/main'
    @cucumber_runtime = Cucumber::Runtime.new
  end

  def cucumber(argv=ARGV)
    cucumber_main = Cucumber::Cli::Main.new(argv.dup)
    had_failures = cucumber_main.execute!(@cucumber_runtime)
    exit_code = had_failures ? 1 : 0
    exit exit_code
  end
end

Zeus.plan = NoSmartypants.new
