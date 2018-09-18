class Onboarding < ApplicationRecord
  attr_accessible :bubble_api_state, :bubble_deployment_state, :bubble_metric_state,
                  :bubble_mapping_state, :bubble_limit_state, :wizard_state

  belongs_to :account

  validates :account_id, presence: true

  def self.null
    new
  end


  BUBBLES = %I[api metric mapping limit deployment].freeze.each do |name|
    initial = "#{name}_pending"
    done = "#{name}_done"
    trigger =  "set_#{name}"

    state_machine "bubble_#{name}_state", :initial => initial do
      state initial
      state done

      event trigger do
        transition initial => done
      end
    end

    private trigger
  end


  state_machine :wizard_state, :initial => :initial, :namespace => 'wizard' do

    event :start do
      transition any - [ :completed, :started ] => :started, if: :valid?
    end

    event :finish do
      transition any => :completed
    end

  end

  def active?
    persisted? && !process_finished?
  end

  def process_finished?
    BUBBLES.all? { |bubble| public_send "#{bubble}_done?" }
  end

  def finish_process!
    BUBBLES.map(&method(:bubble_update)).all?
  end

  def wizard_started?
    wizard_state?(:started)
  end

  def wizard_start
    start_wizard
  end

  def wizard_finish
    finish_wizard
  end

  def bubble_update(bubble_name)
    updated = fire_events("set_#{bubble_name}")

    if updated
      ThreeScale::Analytics.current_user.track('Finished Onboarding Bubble', bubble: bubble_name)
    end

    updated
  end


  def bubbles
    BUBBLES.map do |bubble|
      bubble if public_send("#{bubble}_pending?")
    end.compact
  end
end
