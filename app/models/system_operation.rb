class SystemOperation < ApplicationRecord
  has_many :messages
  has_many :mail_dispatch_rules, :dependent => :destroy

  validates :ref, uniqueness: true
  validates :ref, :name, length: {maximum: 255}

  DEFAULTS = {'user_signup'            => 'New user signup',
              "new_app"                => "New application created",
              "new_contract"           => "New service subscription",
              "app_suspended"          => "Application suspended",
              "contract_suspended"     => "Service subscription suspended",
              "key_created"            => "Application key created",
              "key_deleted"            => "Application key deleted",
              'new_message'            => 'Receiving a new message',
              'plan_change'            => 'Plan change by a user',
              'new_forum_post'         => "New forum post",
              'limit_alerts'           => 'Limit alerts and violations',
              'cinstance_cancellation' => 'User cancels account',
              'contract_cancellation'  => 'Service subscription cancelation',
              'weekly_reports'         => 'Weekly aggregate reports',
              'daily_reports'          => 'Daily aggregate reports',
              'plan_change_request'    => 'Request to change plan' }.with_indifferent_access

  scope :defaults, -> { where(:ref => DEFAULTS.keys)}


  default_scope -> do
    create_defaults! if defaults.size < DEFAULTS.keys.size
    all
  end

  class << self
    def for(ref)
      return unless ref.present?

      sys_op = find_by_ref(ref.to_s)

      if sys_op
        sys_op
      elsif DEFAULTS[ref]
        SystemOperation.create! :ref => ref.to_s, :name => DEFAULTS[ref]
      else
        raise "Unknown System Operation: #{ref}"
      end
    end

    def update_missing_pos
      max = self.maximum(:pos) || 0
      self.where({:pos => nil}).find_each do |op|
        op.update_attribute( :pos, max += 10 )
      end
    end

    private

    def create_defaults!
      Rails.logger.warn 'Creating SystemOperation defaults'
      create(DEFAULTS.map{|ref, name| {:ref => ref, :name => name }})
    end
  end
end
