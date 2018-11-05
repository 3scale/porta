# Jobs code lists extracted to constants for easier testing.
# See config/jobs.rb for details.
#
# TODO - this is kind of hack ... remove it
require File.expand_path(File.join(File.dirname(__FILE__), 'jobs'))

env :PATH, '/home/bender/bin:/home/bender/.rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games'
bundle_gemfile_env = ENV.fetch('BUNDLE_GEMFILE', 'Gemfile')

set :output, { standard: '/var/log/cron.output' }
env :MAILTO, ENV.fetch('SYSADMIN_EMAIL', '') # TODO: I'm not entirely convinced by this

bundle_path = ENV.fetch('BUNDLE_BIN_PATH') { `which bundle`.strip }

set :bundle_command, "BUNDLE_GEMFILE=#{bundle_gemfile_env} #{Gem.ruby} #{bundle_path} exec"
set :runner_command, "script/rails runner"
set :rake_command, " #{`which rake`.strip}"
set :ruby_command, Gem.ruby.to_s

job_type :rake, "cd :path && :environment_variable=:environment :bundle_command :rake_command :task --silent :output"
job_type :ruby, "cd :path && :bundle_command :ruby_command :task :output"

job_proc = ThreeScale::Jobs::JOB_PROC

every :month, roles: [:cron] do
  ThreeScale::Jobs::MONTH.each { |task| instance_exec(task, &job_proc) }
end

# every week on Monday
every '0 0 * * 1', roles: [:cron] do
  ThreeScale::Jobs::WEEK.each { |task| instance_exec(task, &job_proc) }
end

every :hour, roles: [:cron] do
  ThreeScale::Jobs::HOUR.each { |task| instance_exec(task, &job_proc) }
end

ThreeScale::Jobs::DAILY.each_with_index do |task, index|
  every :day, at: "#{8+index}:00", roles: [:cron] do
    instance_exec(task, &job_proc)
  end
end

every :day, :at => '08:00', roles: [:cron] do
  ThreeScale::Jobs::BILLING.each { |task| instance_exec(task, &job_proc) }
end

ThreeScale::Jobs::CUSTOM.each_pair do |interval, task|
  every interval, roles: [:cron] do
    instance_exec(task, &job_proc)
  end
end

every 1.day, :at => '6:00 am', roles: [:sphinx_server] do
  ThreeScale::Jobs::SPHINX_INDEX.each { |task| instance_exec(task, &job_proc) }
end

# every hour would put at minute 0 which is quite busy with tasks already
every '42 * * * *', roles: [:sphinx_server] do
  ThreeScale::Jobs::SPHINX_DELTA.each { |task| instance_exec(task, &job_proc) }
end
