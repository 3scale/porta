# frozen_string_literal: true

Given 'there are no enqueued jobs' do
  Sidekiq::Job.clear_all
end
