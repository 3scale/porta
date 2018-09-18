require 'color'

namespace :ci do
  task :lint do
    results = %w[jspm].map do |name|
      task = Rake::Task["lint:#{name}"]

      if (pid = fork)
        _, status = Process.wait2(pid)

        success = status.success?

        puts
        puts "#{Color::BOLD}rake #{task.name} #{success ?
                 "#{Color::GREEN}succeeded#{Color::CLEAR}" :
                 "#{Color::RED}failed#{Color::CLEAR}" }"

        [name, success]
      else
        puts "Running: #{task.name}"
        task.invoke
        exit
      end
    end.to_h

    puts

    failures = results.select{|_,success| !success }

    results.values.all? or
        abort "#{Color::RED}#{Color::BOLD}rake ci:lint failed: #{failures.keys.join(', ')}#{Color::CLEAR}"
  end
end
