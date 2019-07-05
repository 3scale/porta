# frozen_string_literal: true

require 'test_helper'

class SeedsTest < ActiveSupport::TestCase
  setup do
    with_fake_env('test_seed') do
      System::Application.load_tasks
      Rake::Task['db:create'].invoke
      Rake::Task['db:schema:load'].invoke
    end

  end

  attr_reader :env

  teardown do
    with_fake_env('test_seed') { Rake::Task['db:drop'].invoke }
  end

  test 'the seeds do not fail' do
    ActiveRecord::Base.establish_connection(:test_seed)
    assert Rails.application.load_seed
    ActiveRecord::Base.establish_connection(:test)
  end

  private

  def with_fake_env(new_env)
    old_env = Rails.env
    begin
      Rails.env = ENV['RAILS_ENV'] = new_env
      yield
    ensure
      Rails.env = ENV['RAILS_ENV'] = old_env
    end
  end
end
