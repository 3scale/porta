# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  if System::Database.mysql?
    require 'three_scale/will_paginate_mysql_deferred_lookup'

    WillPaginate::ActiveRecord::RelationMethods.prepend(ThreeScale::WillPaginateMysqlDeferredLookup)
  end
end

