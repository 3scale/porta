class DataExportMailer < ActionMailer::Base
  include CMS::EmailTemplate::MailerExtension
  include Liquid::Assigns

  def export_data(recipient, report_type, files = {})

    provider = recipient.account
    stash =  { report_name: report_type,
               name: recipient.first_name,
               domain_name: provider.domain }
    assign_drops(stash)


    files.each do |name, file|
      attachments[name] = file
    end

    mail(from: Rails.configuration.three_scale.support_email,
         to: recipient.email,
         subject: "#{report_type.humanize} Data Export for #{provider.org_name}",
         template_path: 'emails',
         template_name: "data_export")
  end
end
