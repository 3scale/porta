# frozen_string_literal: true

require 'color'
require 'benchmark'


def print_banner_around
  lambda do |line|
    puts
    puts "=" * 40
    puts "== #{Color::BOLD}#{line}#{Color::CLEAR}"
    puts "=" * 40
    puts

    line
  end
end

def resolve_test_directories

  directories_requiring_to_run_in_different_job_or_without_tests = %w[test_helpers fixtures shoulda_macros factories remote performance].map {|x| "test/#{x}"}

  Pathname.new("test").children.select(&:directory?).map(&:to_s) - directories_requiring_to_run_in_different_job_or_without_tests

end

# rubocop:disable MethodLength
def test_commands
  tags_for_test_categories = %w[
    @backend
    @emails
    @stats
    @search
    @no-txn
  ]

  test_dirs = resolve_test_directories

  {
    :cucumber_javascript => 'parallel_cucumber --verbose features -o "-b -p parallel --tags=@javascript --tags=~@fakeweb --tags=~@percy"',
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





desc 'The default execution: the whole CI suite'
task :integrate => 'integrate:parallel'


namespace :integrate do

  desc 'Runs the set of tests passed as an argument, pretty formatting results, creating reports, etc.'
  task :run_tests, [:some_tests] do |t, args|
    success = "#{Color::GREEN}SUCCESS#{Color::CLEAR_COLOR}"
    failure = "#{Color::RED}FAILURE#{Color::CLEAR_COLOR}"
    banner = print_banner_around

    require 'ci_reporter_shell'
    report = CiReporterShell.report('tmp/junit')

    command = nil
    result = report.execute(args.some_tests, env: {RAILS_ENV: Rails.env}) do |cmd|
      banner.call("BEGIN: #{cmd}")
      command = cmd
    end

    banner.call("FINISH (#{result.success? ? success : failure}): #{command} in #{format('%.1fs', result.time)}")

    abort "#{args.some_tests} FAILED" unless result.success?

  end

  task :cucumber_javascript => :prepare do
    Rake::Task['integrate:run_tests'].invoke(test_commands[:cucumber_javascript])
  end

  task :rspec => :prepare do
    Rake::Task['integrate:run_tests'].invoke(test_commands[:rspec])
  end

  task :integration => :prepare do
    Rake::Task['integrate:run_tests'].invoke(test_commands[:integration])
  end

  task :swagger => :prepare do
    Rake::Task['integrate:run_tests'].invoke(test_commands[:swagger])
  end

  task :frontend => :prepare do
    Rake::Task['integrate:run_tests'].invoke(test_commands[:frontend])
  end

  task :functional => :prepare do
    Rake::Task['integrate:run_tests'].invoke(test_commands[:functional])
  end

  task :main_suite => :prepare do
    Rake::Task['integrate:run_tests'].invoke(test_commands[:main_suite])
  end

  task :cucumber_non_tagged => :prepare do
    Rake::Task['integrate:run_tests'].invoke(test_commands[:cucumber_non_tagged])
  end

  task :cucumber_for_categories => :prepare do
    Rake::Task['integrate:run_tests'].invoke(test_commands[:cucumber_for_categories])
  end

  task :license_checks => :prepare do
    Rake::Task['integrate:run_tests'].invoke(test_commands[:license_checks])
  end

  task :percy => :prepare do
    Rake::Task['integrate:run_tests'].invoke(test_commands[:percy])
  end


  desc 'Runs subset of full test suite, in parallel (1/8)'
  task :parallel_1 => %i[cucumber_javascript rspec]

  desc 'Runs subset of full test suite, in parallel (2/8)'
  task :parallel_2 => [:integration]

  desc 'Runs subset of full test suite, in parallel (3/8)'
  task :parallel_3 => [:integration]

  desc 'Runs subset of full test suite, in parallel (4/8)'
  task :parallel_4 => %i[functional main_suite]

  desc 'Runs subset of full test suite, in parallel (5/8)'
  task :parallel_5 => [:cucumber_non_tagged]

  desc 'Runs subset of full test suite, in parallel (6/8)'
  task :parallel_6 => [:cucumber_for_categories]



  desc 'Runs the whole continuous integration test suite'
  task :parallel, [:log] => %i[verify_empty_reports_folder prepare] do |t, args|

    if ENV['CI']
      ENV['COVERAGE'] = '1'
      ENV['PERCY_ENABLE'] = '0' # percy will be enabled just for one task
    end

    banner = print_banner_around


    time = Benchmark.measure do

      Rake::Task['integrate:parallel_1'].invoke
      Rake::Task['integrate:parallel_2'].invoke
      Rake::Task['integrate:parallel_3'].invoke
      Rake::Task['integrate:parallel_4'].invoke
      Rake::Task['integrate:parallel_5'].invoke
      Rake::Task['integrate:parallel_6'].invoke
      Rake::Task['integrate:license_checks'].invoke
    end

    # TODO: print summary
    banner.call("Finished in #{format('%.1fs', time.real)}\n\t")

    Rake::Task['integrate:report_coverage_to_codeclimate'].invoke(7)


  end

  desc 'Report code coverage to CodeClimate'
  task :report_coverage_to_codeclimate, :number_of_groups  do |t, args|
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

  desc 'Ensures that the test reports folder is empty'
  task :verify_empty_reports_folder do
    junit = Dir['tmp/junit/**']

    if junit.present?
      puts 'WARNING: tmp/junit is not empty'
      puts junit
      abort 'Will not continue, tmp/junit is not empty'
    end

  end


  task :prepare do
    silence_stream(STDOUT) do
      require 'system/database'
      ParallelTests::Tasks.run_in_parallel('RAILS_ENV=test rake db:drop db:create db:schema:load multitenant:triggers')
      Rake::Task['ts:configure'].invoke
    end
  end

end
