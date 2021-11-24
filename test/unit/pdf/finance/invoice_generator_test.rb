# frozen_string_literal: true

require 'test_helper'

class Pdf::Finance::InvoiceGeneratorTest < ActiveSupport::TestCase
  LOGO_PICTURE = "#{Rails.root}/test/fixtures/wide.jpg"

  LONG_ADDRESS =     [%w[Name Farnsworth],
                      ['Address', "AAA\n" * 5],
                      %w[Country Patagonia]].freeze

  setup do
    cinstance = FactoryBot.create(:cinstance)
    @invoice = FactoryBot.create(:invoice, :buyer_account => cinstance.buyer_account )
    @data = Pdf::Finance::InvoiceReportData.new(@invoice)
    @generator = Pdf::Finance::InvoiceGenerator.new(@data)
  end

  # TODO: better to use stubbing
  # TODO: better to test in InvoiceAttachment
  test 'should generate attachment with correct file name' do
    @invoice.provider_account.update_attribute(:org_name, 'YOU')
    @invoice.buyer_account.update_attribute(:org_name, 'ME')
    @invoice.update_attribute(:created_at, Time.zone.local(1984, 1, 31))
    attachment = @generator.generate_as_attachment

    assert_equal 'invoice-january-1984.pdf', attachment.original_filename
    assert_equal 'application/pdf', attachment.content_type
  end

  test 'should generate valid PDF content with logo and line items' do
    @data.stubs(:logo?).returns(true)
    @data.stubs(:logo).returns(LOGO_PICTURE)
    @data.stubs(:provider).returns(LONG_ADDRESS)
    items = [['Licorice', '5', '222', ''],
             ['Haribo  ', '11', '11', ''],
             ['Chocolatte', '', '11', ''],
             ['Sugar', nil, '11', '']]

    @data.stubs(:line_items).returns(items)

    content = @generator.generate
    assert_not_nil content
  end
end
