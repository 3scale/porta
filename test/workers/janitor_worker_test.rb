# frozen_string_literal: true

require 'test_helper'

class JanitorWorkerTest < ActiveSupport::TestCase
  def test_perform
    ThreeScale.config.stubs(janitor_worker_enabled: true)

    mock_purge_workers(called_times: 'once')

    JanitorWorker.new.perform
  end

  def test_not_enabled
    ThreeScale.config.stubs(janitor_worker_enabled: false)

    mock_purge_workers(called_times: 'never')

    refute JanitorWorker.new.perform
  end

  def mock_purge_workers(called_times:)
    PurgeOldUserSessionsWorker.expects(:perform_async).send(called_times)
    PurgeStaleObjectsWorker.expects(:perform_later).send(called_times).with(EventStore::Event.name, Alert.name, DeletedObject.name)
  end
end
