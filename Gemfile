# frozen_string_literal: true

ruby File.read('.ruby-version', mode: 'rb').chomp.prepend('~> ')

eval_gemfile 'Gemfile.base'
gem 'pg', '~> 0.21.0'
gem 'sidekiq-batch', '~> 0.1.1'
