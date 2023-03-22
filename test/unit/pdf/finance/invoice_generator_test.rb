# frozen_string_literal: true

require 'test_helper'

class Pdf::Finance::InvoiceGeneratorTest < ActiveSupport::TestCase
  fixtures :countries

  LONG_ADDRESS = [%w[Name Farnsworth],
                  ['Address', %{JOHN "GULLIBLE" DOE\nCENTER FOR FINANCIAL ASSISTANCE TO DEPOSED NIGERIAN ROYALTY\n421 E DRACHMAN
  TUCSON AZ 85705-7598}],
                  %w[Country Patagonia]].freeze

  setup do
    cinstance = FactoryBot.create(:cinstance)
    @invoice = FactoryBot.create(:invoice, buyer_account: cinstance.buyer_account, created_at: Time.zone.local(1984, 1, 31))
    @data = Pdf::Finance::InvoiceReportData.new(@invoice)
    @generator = Pdf::Finance::InvoiceGenerator.new(@data)
  end

  # TODO: better to use stubbing
  # TODO: better to test in InvoiceAttachment
  test 'should generate attachment with correct file name' do
    @invoice.provider_account.update(org_name: 'YOU')
    @invoice.buyer_account.update(org_name: 'ME')
    attachment = @generator.generate_as_attachment

    assert_equal 'invoice-january-1984.pdf', attachment.original_filename
    assert_equal 'application/pdf', attachment.content_type
  end

  test 'should generate valid PDF content with logo and line items' do
    logo_file = File.open(file_fixture('wide.jpg'), 'rb')
    @data.expects(:with_logo).yields(logo_file)
    @data.stubs(:provider).returns(LONG_ADDRESS)
    items = [['Licorice', '5', '222', ''],
             ['Haribo  ', '11', '11', ''],
             ["Chocolatte#{Prawn::Text::NBSP}", '', '11', ''],
             ['Sugar', nil, '11', '']]

    @data.stubs(:line_items).returns(items)

    content = @generator.generate
    assert_not_nil content

    # ensure an image is present in the PDF
    assert_equal 1, content.scan(%r{/Type /XObject}).size

    strings = PDF::Inspector::Text.analyze(content).strings
    flat_items = items.flatten.reject(&:blank?).map(&:strip)
    flat_items.each { |item| assert_includes strings, item }
    assert_includes strings, "Chocolatte#{Prawn::Text::NBSP}" # prawn should not strip non-breaking spaces

    # Address tables should not wrap header words
    assert_equal 3, strings.count("Address")
    assert_equal 3, strings.count("Country")
  ensure
    logo_file.close
  end

  test "multi-page with headers and zero vat" do
    15.times.map do |idx|
      @invoice.line_items.build(name: "Item #{idx}", quantity: rand(1..100), cost: rand(1.0..101.0))
    end

    buyer = @invoice.buyer
    buyer.vat_rate = 0
    buyer.po_number = random_word(chars: ('0'..'9').to_a, first_char: ('0'..'9').to_a)
    buyer.vat_code = random_word(min_size: 10, chars: ('0'..'9').to_a)
    buyer.fiscal_code = random_word(min_size: 10, chars: ('0'..'9').to_a)
    set_random_address(buyer)
    buyer.save!

    provider = @invoice.provider
    set_random_address(provider)
    provider.vat_code = random_word(min_size: 10, chars: ('0'..'9').to_a)
    provider.fiscal_code = random_word(min_size: 10, chars: ('0'..'9').to_a)
    provider.invoice_footnote = "FOOT: #{random_sentence}"
    provider.vat_zero_text = "◦ zero vat: #{random_sentence}"
    provider.save!

    @invoice.issue_and_pay_if_free!
    content = @generator.generate
    strings = PDF::Inspector::Text.analyze(content).strings

    # We do not have "◦ zero vat" string because prawn embeds TTF subsets and that unicode char is in another one
    # so basically in the resulting PDF, it is another string with another font.
    assert(strings.any? { |str| str.start_with? "◦" })
    assert(strings.any? { |str| str.include? "zero vat: " })
    assert(strings.any? { |str| str.start_with? "FOOT: " })
    assert_equal 3, strings.count("Fiscal code")
  end

  private

  def set_random_address(account)
    account.country_id = Country.ids.sample
    account.billing_address = {
      # name: billing_address_name.presence || org_name,
      address1: "#{random_sentence}",
      address2: "#{rand(999)} #{random_word}' Avenue #{rand(200)}",
      # country: billing_address_country || default_country,
      city: random_word,
      state: random_word,
      zip: format("%5d", rand(99999)),
      phone: "+1#{format("%7d", rand(9999999))}",
    }
  end

  def random_word(min_size: 3, max_size: 10, chars: ("a".."z").to_a, first_char: ("A".."Z").to_a)
    max_size -= 1
    min_size -= 1
    first_char.sample + rand(min_size..max_size).times.map { chars.sample }.join
  end

  def random_sentence
    rand(3..5).times.map { random_word }.join(" ")
  end
end
