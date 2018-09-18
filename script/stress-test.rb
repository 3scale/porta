#!/usr/bin/env ruby

require 'thor'
require 'parallel'



$: << File.dirname(__FILE__)

class StressTest < Thor

  desc "signup PREFIX", "signs providers with PREFIX as org name"
  option :count, :type => :numeric, :required => true, :default => 1
  option :url, :desc => 'full url to signup'
  option :async, :type => :boolean, :default => false

  def signup(prefix)
    require 'stress-test/signup'
    async = options[:async]
    count = options[:count].to_i

    count.times do |i|
      signup = Signup.new(prefix, i, options)
      signup = signup.async if async
      signup.post
    end
  end

  desc "provider URL", "starts clicking around as provider on that base URL"

  option :delay,   :type => :numeric, :default => 5
  option :spread,  :type => :numeric, :default => 0,
         :desc => 'Float number between 0 and 1 to randomize the delay.
                   Example: delay 1 with spread 0.7 will wait from 0.3 to 1.7 seconds'
  option :workers, :type => :numeric, :default => 1,
                   :desc => 'How many workers (processes) to spawn'

  option :username, :type => :string, :default => 'user'
  option :password, :type => :string, :default => 'password'
  option :access_code, :type => :string
  option :provider_key,  :type => :string

  def provider(url_string)
    require 'stress-test/provider_clicking'
    require 'stress-test/api_hitting'

    url = URI.parse(url_string)
    provider_key = options[:provider_key]
    delay = options[:delay]
    spread = options[:spread]
    username = options[:username]
    password = options[:password]
    access_code = options[:access_code]
    workers = options[:workers].to_i

    delay = delay * (1 - spread) .. delay * (1 + spread)

    task = if provider_key
             APIHitting.new(url, provider_key)
           else
             ProviderClicking.new(url, username, password, access_code)
           end

    job = Proc.new do |i|
      loop do
        name = nil
        time = Benchmark.realtime { name = task.perform! }
        puts [i, "Completed", "#{name}:", "#{time.round(2)}s"].compact.join(' ')
        sleep rand(delay)
      end
    end

    if workers > 1
      Parallel.each(workers.times, :in_processes => workers, &job)
    else
      job.call(nil)
    end
  end
end

StressTest.start(ARGV)
