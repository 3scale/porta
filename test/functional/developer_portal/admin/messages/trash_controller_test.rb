require 'test_helper'

class DeveloperPortal::Admin::Messages::TrashControllerTest < DeveloperPortal::ActionController::TestCase
  with_options :controller => 'messages/trash' do |test|
    test.should route(:get, '/admin/messages/trash').to :action => 'index'
    test.should route(:get, '/admin/messages/trash/42').to :action => 'show', :id => '42'
    test.should route(:delete, '/admin/messages/trash/42').to :action => 'destroy', :id => '42'
    test.should route(:delete, '/admin/messages/trash').to :action => 'empty'
  end
end
