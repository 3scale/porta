require "codeclimate_rails/version"

require 'codeclimate-test-reporter'

require 'codeclimate_batch'

module CodeclimateRails

  module Git
    def info
      {
          committed_at: git_timestamp,
          head: head,
          branch: branch
      }
    end

    def service_data
      @service_data ||= CodeClimate::TestReporter::Ci.service_data
    end

    private

    def git(*)
      ''
    end

    def head
      service_data[:commit_sha]
    end

    def branch
      service_data[:branch].to_s.strip.sub(/^origin\//, '')
    end

    def git_timestamp
      (timestamp = ENV['GIT_TIMESTAMP']) ? timestamp.to_i : nil
    end
  end

  def self.start
    return unless ENV['CI']

    if ENV['COVERAGE']
      CodeClimate::TestReporter.configure do |config|
        config.profile = 'rails'
        config.branch = 'master'
      end

      CodeclimateBatch.start
    else
      warn 'Missing COVERAGE variable. Not enabling CodeClimate coverage tracking.'
    end
  end

end

CodeClimate::TestReporter::Git.singleton_class.prepend(CodeclimateRails::Git)

