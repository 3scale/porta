# frozen_string_literal: true

require 'color'
require 'benchmark'


desc 'The default execution: the whole CI suite'
task :integrate => 'integrate:parallel'


namespace :integrate do

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

      obsolete_tests = %w[remote performance].map {|x| "test/#{x}"}

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
    def self.test_commands
      tags_for_test_categories = %w[
        @backend
        @emails
        @stats
        @search
        @no-txn
      ]

      test_dirs = resolve_test_groups_by_path

      {
        :cucumber_javascript => 'parallel_cucumber --verbose features -o "-b -p parallel --tags=@javascript --tags=~@fakeweb --tags=~@percy --tags=~@ignore"',
        :cucumber_non_tagged => %(parallel_cucumber --verbose features -o "-b -p parallel --tags=~@javascript #{tags_for_test_categories.map {|t| %(--tags=~#{t})}.join(' ')}"),
        :cucumber_for_categories => %(parallel_cucumber --verbose features -o "-b -p parallel --tags=~@javascript --tags=#{tags_for_test_categories.join(',')}"),

        :rspec => 'parallel_rspec --verbose spec',
        :integration => "parallel_test --verbose #{test_dirs.delete('test/integration')}",
        :swagger => [
          'rake doc:swagger:validate:all',
          'rake doc:swagger:generate:all',
        ],
        :frontend => [
          'rake ci:jspm --trace',
          'yarn test -- --reporters dots,junit --browsers Firefox',
          'yarn jest',
          'rake db:purge db:setup',
        ],
        :functional => "parallel_test --verbose #{test_dirs.delete('test/functional')}",
        :license_checks => "export http_proxy=#{ENV['http_proxy']} https_proxy=#{ENV['https_proxy']}; rake ci:license_finder:run",
        :main_suite => "parallel_test --verbose #{test_dirs.join(' ')}",
        :percy => 'PERCY_ENABLE=1 cucumber -b -p parallel --tags=@percy features',
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
  orchestration_helpers.test_commands.each_key do |command|
    desc "Runs tests with #{command}"
    task command.to_s => :prepare do
      orchestration_helpers.run_tests(orchestration_helpers.test_commands[command])
    end
  end

  desc 'Runs subset of full test suite, in parallel (1/8)'
  task :parallel_1 => %i[prepare cucumber_javascript rspec]

  desc 'Runs subset of full test suite, in parallel (2/8)'
  task :parallel_2 => %i[prepare integration]

  desc 'Runs subset of full test suite, in parallel (3/8)'
  task :parallel_3 => %i[prepare integration]

  desc 'Runs subset of full test suite, in parallel (4/8)'
  task :parallel_4 => %i[prepare functional main_suite]

  desc 'Runs subset of full test suite, in parallel (5/8)'
  task :parallel_5 => %i[prepare cucumber_non_tagged]

  desc 'Runs subset of full test suite, in parallel (6/8)'
  task :parallel_6 => %i[prepare cucumber_for_categories]



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
