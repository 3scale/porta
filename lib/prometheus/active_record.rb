# frozen_string_literal: true

Yabeda.configure do
  group :rails_connection_pool do
    size = gauge :size, comment: 'Size of the connection pool'
    connections = gauge :connections, comment: 'Number of connections in the connection pool', tags: %i[state]
    waiting = gauge :waiting, comment: 'Number of waiting in the queue of the connection pool'

    no_labels = {}.freeze
    busy = { state: :busy }.freeze
    dead = { state: :dead }.freeze
    idle = { state: :idle }.freeze

    collect do
      stat = ActiveRecord::Base.connection_pool.stat

      size.set(no_labels, stat.fetch(:size))
      connections.set(no_labels, stat.fetch(:connections))
      connections.set(busy, stat.fetch(:busy))
      connections.set(dead, stat.fetch(:dead))
      connections.set(idle, stat.fetch(:idle))
      waiting.set(no_labels, stat.fetch(:waiting))
    end
  end
end
