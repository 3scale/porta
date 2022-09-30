# frozen_string_literal: true

require 'test_helper'

class Pdf::Finance::InvoiceReportDataTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_with_billing)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @invoice = FactoryBot.create(:invoice, provider_account: @provider, buyer_account: @buyer)
    @data = Pdf::Finance::InvoiceReportData.new(@invoice)
  end

  test 'not change total without VAT rate' do
    @invoice.line_items.create :name => 'Junk', :cost => 42

    assert_equal ["Junk", "", 42, ''], @data.line_items[0]
    assert_equal ["Total cost", "", 42, 42], @data.line_items[1]
  end

  test 'respect the defined labels of fields' do
    FactoryBot.create(:fields_definition, target: 'Account', name: 'vat_code', label: 'ABN', account: @provider)
    FactoryBot.create(:fields_definition, target: 'Account', name: 'vat_rate', label: 'GST', account: @provider)
    @buyer.vat_code = '5555'
    @buyer.save!

    @invoice.reload

    assert_equal 'ABN', @data.buyer[3][0]
  end

  test 'respect the defined labels of fields with default value' do
    @buyer.vat_code = '5555'
    @buyer.save!

    @invoice.reload
    assert_equal 'VAT Code', @data.buyer[3][0]
  end

  test 'respect and provide VAT rate and po number if present' do
    @buyer.fiscal_code = 'chino22'
    @buyer.vat_code = 'vat55'
    @buyer.vat_rate = 2.34
    @buyer.po_number = 'po123s'
    @buyer.save!

    @invoice.reload
    @invoice.line_items.create :name => 'Junk', :cost => 10000

    assert_equal ['Fiscal code', 'chino22'], @data.buyer[3]
    assert_equal ['VAT Code', 'vat55'], @data.buyer[4]
    assert_equal ['PO num', 'po123s'], @data.buyer[5]

    assert_equal [["Junk", "", 10000.0, ''],
                  ["Total cost (without Vat rate)",  "", 10000.0, 10000.0 ],
                  ["Total Vat rate Amount",  "", 234.0, 234.0 ],
                  ["Total cost (Vat rate 2.34% included)", "", '', 10234.0 ]], @data.line_items
  end

  test 'respect and provide VAT rate and po number if present and modified by provider' do
    FactoryBot.create(:fields_definition, target: 'Account', name: 'vat_code', label: 'ABN', account: @provider)
    FactoryBot.create(:fields_definition, target: 'Account', name: 'vat_rate', label: 'GST', account: @provider)

    @buyer.fiscal_code = 'chino22'
    @buyer.vat_code = 'vat55'
    @buyer.vat_rate = 2.34
    @buyer.po_number = 'po123s'
    @buyer.save!

    @invoice.reload
    @invoice.line_items.create :name => 'Junk', :cost => 10000

    assert_equal ['Fiscal code', 'chino22'], @data.buyer[3]
    assert_equal ['ABN', 'vat55'], @data.buyer[4]
    assert_equal ['PO num', 'po123s'], @data.buyer[5]

    assert_equal [["Junk", "", 10000.0, ''],
                  ["Total cost (without GST)",  "", 10000.0, 10000.0],
                  ["Total GST Amount",  "", 234.0, 234.0],
                  ["Total cost (GST 2.34% included)", "", '', 10234.0]], @data.line_items
  end


  # Regression test for https://3scale.hoptoadapp.com/errors/7206313
  #
  test 'not be vulnerable to XSS attack' do
    @provider.update_attribute(:org_name, '<ScRipT>alert("address1")</ScRipT>')
    assert_equal @data.provider[0][1], '&lt;ScRipT&gt;alert(&quot;address1&quot;)&lt;/ScRipT&gt;'
  end

  test '#with_logo yields to a block with open file and close is after' do
    @provider.profile.update(logo: Rack::Test::UploadedFile.new(file_fixture('wide.jpg'), 'image/jpeg', true))

    logo_file = nil
    @data.with_logo do |logo|
      logo_file = logo
      assert logo.is_a? File
      assert logo&.binmode?
      assert logo.respond_to?(:read)
    end
    assert logo_file&.closed?
  end

  test '#with_logo yields nil if logo not set' do
    @provider.profile.update(logo: nil)

    @data.with_logo do |logo|
      assert logo.nil?
    end
  end

  test '#with_logo calls S3 URL if S3 is used for storage' do
    default_options = Paperclip::Attachment.default_options
    Paperclip::Attachment.stubs(default_options: default_options.merge(storage: :s3))
    @provider.profile.update(logo: Rack::Test::UploadedFile.new(file_fixture('wide.jpg'), 'image/jpeg', true))
    URI.stubs(:open).returns(File.open(file_fixture("wide.jpg")))

    logo_file = nil
    @data.with_logo do |logo|
      logo_file = logo
      assert logo.is_a? File
      assert logo.respond_to?(:read)
    end
    assert logo_file&.closed?
  end
end
