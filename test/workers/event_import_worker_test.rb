require 'test_helper'

class EventImportWorkerTest < MiniTest::Unit::TestCase

  def test_perform
    attributes = {foo: 'foo', bar: 'bar'}
    Events::Importer.expects(:import_event!).with(attributes)
    EventImportWorker.new.perform(attributes)
  end
end
