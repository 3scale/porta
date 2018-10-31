# frozen_string_literal: true

require 'color'
require 'benchmark'


desc 'The default execution: the whole CI suite'
task :integrate => 'integrate:parallel'


namespace :integrate do

  test_groups = {
    integration: FileList["test/{integration}/**/*_test.rb"],
    functional: FileList["test/{functional}/**/*_test.rb"],
    rspec: FileList["spec/**/*_spec.rb"],
  }

  test_groups[:unit] = FileList['test/**/*_test.rb'].exclude(*test_groups.values).exclude('test/{performance,remote,support}/**/*')

  namespace :files do
    test_groups.each do |name,file_list|
      desc "Print test files for #{name} test group"
      task name do
        puts file_list
      end
    end
  end


  orchestration_helpers = Module.new do
    def self.print_banner_around
      lambda do |line|
        puts
        puts "=" * 40
        puts "== #{Color::BOLD}#{line}#{Color::CLEAR}"
        puts "=" * 40
        puts

        line
      end
    end

    def self.get_top_level_folder_path(path)
      path.descend.take(2).last
    end

    def self.resolve_test_groups_by_path

      obsolete_tests = %w[remote performance integration functional spec].map {|x| "test/#{x}"}

      test_files = Pathname.glob('test/**/*_test.rb')
      test_groups = test_files.group_by { |path| get_top_level_folder_path(path)}
      test_groups.keys.map(&:to_s) - obsolete_tests

    end

    def self.verify_empty_reports_folder
      junit = Dir['tmp/junit/**']

      return if junit.blank?

      puts 'WARNING: tmp/junit is not empty'
      puts junit
      abort 'Will not continue, tmp/junit is not empty'

    end

    # rubocop:disable MethodLength
    def self.test_commands (test_lists)
      tags_for_test_categories = %w[
        @backend
        @emails
        @stats
        @search
        @no-txn
      ]


      test_dirs = resolve_test_groups_by_path

      {
        :cucumber_javascript => "parallel_cucumber -o '--profile ci' -- $(cucumber --profile list --profile javascript)",
        :cucumber_txn => "parallel_cucumber -o '--profile ci' -- $(cucumber --profile list --profile txn)",
        :cucumber_no_txn => "parallel_cucumber -o '--profile ci' -- $(cucumber --profile list --profile no-txn)",
        :cucumber => (ENV['CIRCLECI']) ?
                       "bundle exec cucumber --profile list --profile default > all_tests &&  export TESTS=$(circleci tests split --split-by=timings all_tests) && bundle exec cucumber --profile ci $TESTS" :
                       "parallel_cucumber  -o '--profile ci' -- $(cucumber --profile list --profile default)",

        :swagger => 'rake doc:swagger:validate:all && rake doc:swagger:generate:all',
        :frontend => 'yarn test -- --reporters dots,junit --browsers Firefox && yarn jest',
        # :license_checks => "export http_proxy=#{ENV['http_proxy']} https_proxy=#{ENV['https_proxy']}; rake ci:license_finder:run",
        :main_suite => "parallel_test --verbose #{test_dirs.join(' ')}",
        :percy => 'PERCY_ENABLE=1 cucumber -b -p parallel --tags=@percy features',

        :rspec => (ENV['CIRCLECI']) ?
                    "bundle exec rspec --format progress `circleci tests glob spec/**/*_spec.rb | circleci tests split --split-by=timings | awk 'BEGIN {ORS=\" \"} {print}'`" :
                    "parallel_rspec --verbose #{test_lists[:rspec]}",
        :functional => "parallel_test -o '--verbose' #{test_lists[:functional]}",
        :integration => "parallel_test -o '--verbose' #{test_lists[:integration]}",
        :unit => "parallel_test -o '--verbose' #{test_lists[:unit]}",

      }

    end
    # rubocop:enable MethodLength

    def self.run_tests(test_command)
      success = "#{Color::GREEN}SUCCESS#{Color::CLEAR_COLOR}"
      failure = "#{Color::RED}FAILURE#{Color::CLEAR_COLOR}"
      banner = print_banner_around

      require 'ci_reporter_shell'
      report = CiReporterShell.report('tmp/junit')

      command = nil
      result = report.execute(test_command, env: {RAILS_ENV: Rails.env}) do |cmd|
        banner.call("BEGIN: #{cmd}")
        command = cmd
      end

      banner.call("FINISH (#{result.success? ? success : failure}): #{command} in #{format('%.1fs', result.time)}")

      abort "#{test_command} FAILED" unless result.success?
    end

  end

  # Dynamically generate all tasks from test_commands
  orchestration_helpers.test_commands(test_groups).each_key do |command|
    desc "Runs tests with #{command}"
    task command.to_s => :prepare do
      puts "Running #{command}..."
      orchestration_helpers.run_tests(orchestration_helpers.test_commands(test_groups)[command])
    end
  end

  task :precompile_assets do

    ENV['RAILS_ENV'] = 'test'
    Rake::Task['assets:precompile'].invoke

    ENV['RAILS_ENV'] = 'production'
    ENV['WEBPACKER_PRECOMPILE'] = 'false'
    Rake::Task['assets:precompile'].invoke

  end

  [:integration, :functional, :cucumber, :cucumber_javascript, :cucumber_no_txn, :cucumber_txn, "ci:license_finder:run", "doc:swagger:validate:all", "doc:swagger:generate:all", "ci:jspm"].each do |depending_task|
    task depending_task => :precompile_assets
  end

  desc 'Runs the whole continuous integration test suite'
  task :parallel, [:log] do

    banner = orchestration_helpers.print_banner_around

    time = Benchmark.measure do

      Rake::Task.tasks.select { |task| task.name =~ /^integrate:parallel_/ }.map(&:invoke)
      Rake::Task['integrate:license_checks'].invoke
    end

    # TODO: print summary
    banner.call("Finished in #{format('%.1fs', time.real)}\n\t")

    Rake::Task['integrate:report_coverage_to_codeclimate'].invoke(7)

  end

  task :report_coverage_to_codeclimate, :number_of_groups  do
    if ENV['COVERAGE']
      puts 'Sending test coverage to CodeClimate'
      FileUtils.cp(Dir["#{Dir.tmpdir}/codeclimate-test-coverage-*"],
                   Rails.root.join('tmp', 'codeclimate').tap(&:mkpath))

      system('codeclimate-batch',
             '--groups', args.number_of_groups.to_s,
             '--host', 'https://cc-3scale-amend.herokuapp.com',
             '--key', ENV.fetch('BUILD_TAG'))
    end
  end

  desc 'Set environment variables on test coverage and percy and prepare database'
  task :prepare do
    if ENV['CI']
      ENV['COVERAGE'] = '1'
      ENV['PERCY_ENABLE'] = '0' # percy will be enabled just for one task
    end

    orchestration_helpers.verify_empty_reports_folder

    silence_stream(STDOUT) do
      require 'system/database'
      ParallelTests::Tasks.run_in_parallel('RAILS_ENV=test rake db:drop db:create db:schema:load db:procedures multitenant:triggers')
      Rake::Task['ts:configure'].invoke
    end
  end

end
