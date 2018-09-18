module EndUsersRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :end_users

  items extend: EndUserRepresenter
end
