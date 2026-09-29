# frozen_string_literal: true

require 'active_record/database_configurations'
require 'system/database'

if System::Database.mysql?
  require 'will_paginate/active_record'
  require 'three_scale/will_paginate_mysql_deferred_lookup'

  WillPaginate::ActiveRecord::RelationMethods.prepend(ThreeScale::WillPaginateMysqlDeferredLookup)
end
