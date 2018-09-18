module UsersRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :users

  items extend: UserRepresenter
end
