require 'color'




def print_banner_around
  banner = ->(line) do
    puts
    puts "=" * 40
    puts "== #{Color::BOLD}#{line}#{Color::CLEAR}"
    puts "=" * 40
    puts

    line
  end
end


def check_that_junit_reports_folder_is_empty
  junit = Dir['tmp/junit/**']

  if junit.present?
    puts 'WARNING: tmp/junit is not empty'
    puts junit
    abort 'Will not continue, tmp/junit is not empty'
  end
end

def resolve_test_directories

  skip_directories_requiring_to_run_in_different_job_or_without_tests = %w{test_helpers fixtures shoulda_macros factories remote performance}.map {|x| "test/#{x}"}

  test_dirs = Pathname.new("test").children.select(&:directory?).map(&:to_s) - skip_directories_requiring_to_run_in_different_job_or_without_tests

end

desc 'Run continuous integration'
task :integrate, :log do |_, args|
  if ENV['CI']
    ENV['COVERAGE'] = '1'
    ENV['PERCY_ENABLE'] = '0' # percy will be enabled just for one task
  end

  check_that_junit_reports_folder_is_empty

  abort 'failed to run integrate:prepare' unless system('rake integrate:prepare --trace')

  tags = %w{
    @backend
    @emails
    @stats
    @search
    @no-txn
  }

  test_dirs = resolve_test_directories

  cucumber_javascript_tests = 'parallel_cucumber --verbose features -o "-b -p parallel --tags=@javascript --tags=~@fakeweb --tags=~@percy"'
  rspec_tests = 'parallel_rspec --verbose spec'
  integration_tests = "parallel_test --verbose #{test_dirs.delete('test/integration')}"
  frontend_tests = [
    'rake doc:swagger:validate:all',
    'rake doc:swagger:generate:all',
    'rake ci:jspm --trace',
    'yarn test -- --reporters dots,junit --browsers Firefox',
    'yarn jest',
    'rake db:purge db:setup',
  ]

  functional_tests = "parallel_test --verbose #{test_dirs.delete('test/functional')}"
  license_checks = "export http_proxy=#{ENV['http_proxy']} https_proxy=#{ENV['https_proxy']}; rake ci:license_finder:run"
  kind = {
    '1' => [
      cucumber_javascript_tests,
      rspec_tests,
    ],
    '2' => [
      integration_tests,
    ],
    '3' => frontend_tests,
    '4' => [
      functional_tests,
      "parallel_test --verbose #{test_dirs.join(' ')}",
    ],
    '5' => [
      %Q{parallel_cucumber --verbose features -o "-b -p parallel --tags=~@javascript #{tags.map{|t| %Q|--tags=~#{t}| }.join(' ')}"},
    ],
    '6' => [
      %Q{parallel_cucumber --verbose features -o "-b -p parallel --tags=~@javascript --tags=#{tags.join(',')}"},
    ],

    'percy' => [
      'PERCY_ENABLE=1 cucumber -b -p parallel --tags=@percy features'
    ],
    'licenses' => [
      license_checks
    ],
    'commit_phase' =>
      frontend_tests +
      [
        rspec_tests,
        license_checks,
      ]
  }

  tasks = ENV['MULTIJOB_KIND'].present? ? kind.fetch(ENV['MULTIJOB_KIND']) : kind.values.flatten

  success, failure = "#{Color::GREEN}SUCCESS#{Color::CLEAR_COLOR}", "#{Color::RED}FAILURE#{Color::CLEAR_COLOR}"

  summary = []

  banner = print_banner_around

  require 'ci_reporter_shell'
  report = CiReporterShell.report('tmp/junit')


  total_time = 0

  results = tasks.map do |task|

    command = nil
    result = report.execute(task, env: {RAILS_ENV: Rails.env}) do |cmd|
      banner.("BEGIN: #{cmd}")
      command = cmd
    end

    summary << banner.("FINISH (#{result.success? ? success : failure}): #{command} in #{'%.1fs' % result.time}")
    total_time += result.time

    result.success?
  end

  banner.("SUMMARY: in #{'%.1fs' % total_time}\n\t#{summary.join("\n\t")}")

  abort "some tasks failed, exitting" unless results.all?

  if ENV['COVERAGE']
    FileUtils.cp(Dir["#{Dir.tmpdir}/codeclimate-test-coverage-*"],
                 Rails.root.join('tmp', 'codeclimate').tap(&:mkpath))

    system('codeclimate-batch',
           '--groups', (kind.keys.size - 1).to_s,
           '--host', 'https://cc-3scale-amend.herokuapp.com',
           '--key', ENV.fetch('BUILD_TAG'))
  end
end

namespace :integrate do

  task :prepare do
    silence_stream(STDOUT) do
      require 'system/database'
      ParallelTests::Tasks.run_in_parallel('RAILS_ENV=test rake db:drop db:create db:schema:load multitenant:triggers')
      Rake::Task['ts:configure'].invoke
    end
  end

end
