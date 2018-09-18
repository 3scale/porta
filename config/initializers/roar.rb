# This monkey patch disables namespaced lookup for representers
# so instead of Admin::Api::Account::AccountRepresenter it searches for AccountRepresenter

require 'roar/rails/formats'

class Roar::Rails::Formats::Path
   def namespace
     super unless match('/api/')
   end
end
