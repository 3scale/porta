require 'minitest_helper'

require 'events/importer'

class Events::ImporterTest < MiniTest::Unit::TestCase

  def test_async_import_event
    Events::Importer.async_import_event!(object: {}, type: 'alert')
    assert_equal 1, EventImportWorker.jobs.size
  end

  def test_import_event
    importer = mock('importer')
    importer.expects(:save!)

    Events::Importer.expects(:for).returns(importer)
    Events::Importer.import_event!({})
  end

  def test_for
    alert = Events::Importer.for stub('event', :type => 'alert', :object => stub)
    assert_instance_of Events::Importers::AlertImporter, alert

    first_traffic = Events::Importer.for stub('event', :type => 'first_traffic', :object => stub)
    assert_instance_of Events::Importers::FirstTrafficImporter, first_traffic

    first_daily_traffic = Events::Importer.for stub('event', :type => 'first_daily_traffic', :object => stub)
    assert_instance_of Events::Importers::FirstDailyTrafficImporter, first_daily_traffic
  end

end
