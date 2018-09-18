module WebHookFailureRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource 'webhooks-failure'

  property :id
  property :time
  property :error
  property :url
  property :event

  def error
    exception
  end

  def event
    xml
  end
end
