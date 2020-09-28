class Onboarding < ApplicationRecord
  attr_accessible :bubble_api_state, :bubble_deployment_state, :bubble_metric_state,
                  :bubble_mapping_state, :bubble_limit_state, :wizard_state

  belongs_to :account

  validates :account_id, presence: true

  def self.null
    new
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
    persisted?
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

end
