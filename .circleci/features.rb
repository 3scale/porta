require 'find'
require 'gherkin/parser'

# In the past we have used: circleci tests glob "features/**/*.feature"

# To prevent seeing "No timing found for" files that have no scenarios
# executed, we filter them here. Presently that is any non-empty features
# with at least one scenario without the `@wip` tag. If our Cucumber
# default tag expression changes, this file will also have to be updated.

class Finder
  def find_in_dir(feature_dir)
    Find.find(feature_dir) do |path|
      next unless path.end_with?(".feature") && File.file?(path)

      process path, parse_feature(path)
    end
  end

  # @param [String] feature the path to a feature file
  # @return [Hash] a gherkin parsed feature
  def parse_feature(feature)
    open(feature) {|io| Gherkin::Parser.new.parse io}
  end

  def process(path, parsed_file)
    if has_any_without_tags?(parsed_file.feature, "@wip")
      puts path
    else
      STDERR.puts %{Skipping @wip feature "#{path}"}
    end
  end

  def has_any_without_tags?(feature, tag)
    !feature.tags.map(&:name).include?(tag) &&
      feature.children.any? do |test_case|
        test_case.scenario &&
          !test_case.scenario.tags.map(&:name).include?(tag) ||
          test_case.respond_to?(:rule) && test_case.rule &&
          has_any_without_tags?(test_case.rule, tag)
      end
  end
end

Finder.new.find_in_dir("features")
