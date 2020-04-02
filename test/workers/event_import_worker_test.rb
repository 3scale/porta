require 'test_helper'

class EventImportWorkerTest < SimpleMiniTest

  def test_perform
    attributes = {foo: 'foo', bar: 'bar'}
    Events::Importer.expects(:import_event!).with(attributes)
    EventImportWorker.new.perform(attributes)
  end
end
