require 'test_helper'

class Events::Importers::BaseImporterTest < ActiveSupport::TestCase

  def setup
    Events::Importers::BaseImporter.clear_cache
  end

  def test_object_service_is_returned_if_present
    service = stub('service')
    importer = Events::Importers::BaseImporter.new(stub('object', service: service))
    assert_equal service, importer.service
  end

  def test_service_is_found_if_service_id_is_present_but_not_service
    service = stub('service')
    ::Service.expects(:find).with(1).returns(service).once
    importer = Events::Importers::BaseImporter.new(stub('object', service: nil, service_id: 1))
    assert_equal service, importer.service
  end

  def test_service_is_cached_by_the_importer_class
    service = stub('service')
    ::Service.expects(:find).with(1).returns(service).once
    importer1 = Events::Importers::BaseImporter.new(stub('object', service: nil, service_id: 1))
    importer2 = Events::Importers::BaseImporter.new(stub('object', service: nil, service_id: 1))

    importer1.service # finds and caches the service
    importer2.service # does not call ::Service.find again
  end

  def test_user_tracking
    cinstance = Cinstance.new
    cinstance.user_account = Account.new
    cinstance.user_account.stubs(admins: [User.new])

    object = stub('object', cinstance: cinstance)
    importer = Events::Importers::BaseImporter.new(object)

    assert importer.user_tracking
    assert importer.user_tracking.user

    cinstance.user_account = Account.new
    cinstance.user_account.stubs(admins: [])

    assert importer.user_tracking
    refute importer.user_tracking.user
  end

end
