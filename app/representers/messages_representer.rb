module MessagesRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :messages

  items extend: MessageRepresenter
end
