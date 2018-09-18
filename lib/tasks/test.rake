namespace :test do
  Rake::TestTask.new(:remote => 'db:test:prepare') do |t|
    t.libs << 'test'
    t.pattern = 'test/remote/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:remote'].comment = 'Run the remote tests in test/remote'

  Rake::TestTask.new(:safe_remote => 'db:test:prepare') do |t|
    t.libs << 'test'
    t.pattern = 'test/remote/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:remote'].comment = 'Run the safe remote tests in test/remote'
end
