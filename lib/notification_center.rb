require 'set'

# Allows you to disable notifications for some classes on per block basis
#
# for example:
#
#   NotificationCenter.silent_about(ApplicationKey) do
#     ApplicationKey.create(params)
#   end
#
# And, the ApplicationKey is defined like:
#
#   after_commit :notify_change, if: :should_notify?
#
#   def should_notify?
#     NotificationCenter.new(self).enabled?
#   end
#
# Then the ApplicationKey#notify_change will not be called when
# called in the block of NotificationCenter.silent_about

class NotificationCenter

  THREAD_LOCAL_VARIABLE = :__notification_center_disabled_set
  private_constant :THREAD_LOCAL_VARIABLE

  def self.silent_about(*kinds, &block)
    original = disabled.dup
    disabled.merge(kinds.flatten)
    yield
  ensure
    self.disabled = original
  end

  def self.include?(kind)
    not disabled?(kind)
  end

  def self.disabled
    Thread.current[THREAD_LOCAL_VARIABLE] ||= empty
  end

  def self.disabled=(val)
    Thread.current[THREAD_LOCAL_VARIABLE] = val
  end

  def self.reset!
    self.disabled = empty
  end

  def self.empty
    Set.new
  end

  def initialize(object)
    @object = object
  end

  def enabled?
    self.class.include?(@object)
  end

  protected

  def self.disabled?(object)
    disabled.any?{|kind| kind === object }
  end

end
