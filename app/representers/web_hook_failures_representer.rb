module WebHookFailuresRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection 'webhooks-failures'

  items extend: WebHookFailureRepresenter
end
