# frozen_string_literal: true

Given 'there are no enqueued jobs' do
  Sidekiq::Worker.clear_all
end
