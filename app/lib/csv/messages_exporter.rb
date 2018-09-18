# frozen_string_literal: true

class Csv::MessagesExporter < ::Csv::Exporter
  def generate
    super do |csv|
      csv << header
      csv << []
      csv << ["Sender", "Organization Name", "Sent At", "Subject", "Message"]

      data = @account.received_messages.where(@range.nil? ? {} : {:"messages.created_at" => @range})
                                       .joins(:message)
                                       .merge(Message.order(created_at: :desc)).find_each do |d|
        detail = if d.sender.nil? || d.sender.admins.first.nil?
                   ['DELETED', "N/A"]
                 else
                   [d.sender.admins.first.username, d.sender.org_name]
                 end
        detail << [d.message.created_at, d.message.subject.strip, d.message.body.strip]
        csv << detail.flatten
      end
    end
  end
end
