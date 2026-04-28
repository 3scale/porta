# frozen_string_literal: true

class UserDecorator < ApplicationDecorator
  delegate :sample_developer_john_doe?, to: :object

  def full_name
    [first_name, last_name].select(&:present?).join(' ')
  end

  def display_name
    full_name.presence || username
  end

  def informal_name
    first_name.presence || last_name.presence || username
  end
end
