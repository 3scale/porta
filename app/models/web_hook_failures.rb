class WebHookFailures
  include Enumerable

  # FIFO of json hashes of provider web hook failures
  # the list is inserted at the tail, read from the head
  # every hash will have an incremental id, so the list will be sorted by the ids

  # webhooks failures hashes look like this
  #   { :id => <uuid>,
  #     :time => <approx time of the last failure>,
  #     :error => <exception of the failure>,
  #     :event => <web hook xml w/o root element> }

  # method to be called from background jobs to add webhook failures to the list
  #

  def self.add(provider_id, exception, id, url, xml)
    failure = WebHook::Failure.new(exception, id, url, xml)
    new(provider_id).add(failure)
  end

  def initialize(provider_id)
    @provider_id = provider_id
  end

  # list id in redis
  #
  def list_id
    "webhooks:failures:provider-#{@provider_id}"
  end

  # confort method to check whether the list is empty
  #
  delegate :empty?, to: :_all

  # inserting at the tail (right-most) of the list
  #
  def add(failure)
    redis.rpush(list_id, failure.to_json)
  end

  # reads first (left-most) element of the list
  #
  def first
    elems = redis.lrange list_id, 0, 0
    #TODO: make HashWithIndifferent access
    WebHook::Failure.parse(elems.first)
  end

  # reads all elements in the list
  #
  def all
    _all.map { |e| WebHook::Failure.parse(e) }
  end

  def to_xml(options = {})
    builder = options[:builder] || ThreeScale::XML::Builder.new
    builder.tag!(options[:root] || 'webhooks-failures') do |xml|
      all.each do |failure|
        failure.to_xml(options.merge(builder: builder))
      end
    end
    builder.to_xml
  end

  # deletes webhook_failures from the list by time
  # the elements get removed if its time < less_than
  #
  def delete_by_time(less_than_time)
    parsed = Time.parse(less_than_time)
    while first && Time.parse(first.time) <= parsed
      redis.lpop list_id
    end
  end

  def delete(time = nil)
    if time
      delete_by_time(time)
    else
      delete_all
    end
  end

  def self.valid_time?(time)
    Time.parse(time) rescue false
  end

  # deletes all webhook_failures from the list
  #
  def delete_all
    redis.del list_id
  end

  def each(&block)
    all.each(&block)
  end

  protected

  def _all
    redis.lrange list_id, 0, -1
  end

  def redis
    @redis ||= System.redis
  end

end
