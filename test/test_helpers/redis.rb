require 'redis'

module TestHelpers
  module Redis
    private

    def self.included(base)
      base.setup :flushdb_redis_server
    end

    def start_redis_server(options = {})
      options.assert_required_keys(:port)

      config_template = File.read(Rails.root.join('test', 'fixtures', 'redis.conf.erb'))
      config_filename = "/tmp/redis-#{options[:port]}.conf"
      config = ERB.new(config_template).result(binding)

      File.open(config_filename, 'w') { |io| io.write(config) }
      system("redis-server #{config_filename} >> /dev/null")
    end

    def shutdown_all_redis_servers
      Dir["/tmp/redis-*.pid"].each do |pid_file|
        port = pid_file[/redis\-(\d+)\.pid$/, 1]
        redis_send(:shutdown, :port => port)
      end
    end

    # Send raw command to redis (via redis-cli)
    def redis_send(*args)
      options = args.extract_options!
      options.assert_required_keys(:port)

      command = "redis-cli -p #{options[:port]} #{args.map(&:to_s).join(' ')}"
      `#{command} 2> /dev/null`
    end

    def generate_redis_port_numbers(count)
      ports = []
      count.times do |index|
        ports << 6380 + index + count * ENV['TEST_ENV_NUMBER'].to_i
      end

      ports
    end

    def flushdb_redis_server
      ::Backend::Storage.instance.flushdb
    rescue Errno::ECONNREFUSED, ::Redis::CannotConnectError, ::Errno::EINVAL
      # server is not running
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Redis)
