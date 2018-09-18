require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Pdf::Finance::InvoiceGeneratorTest < ActiveSupport::TestCase

  LOGO_PICTURE = "#{Rails.root}/test/fixtures/wide.jpg"

  LONG_ADDRESS =     [ [ 'Name',    'Farnsworth' ],
                       [ 'Address', "AAA\n" * 5],
                       [ 'Country', 'Patagonia' ] ]


  context "Pdf::InvoiceGenerator" do
    setup do
      cinstance = Factory(:cinstance)
      @invoice = Factory(:invoice, :buyer_account => cinstance.buyer_account )
      @data = Pdf::Finance::InvoiceReportData.new(@invoice)
      @generator = Pdf::Finance::InvoiceGenerator.new(@data)
    end

    # TODO: better to use stubbing
    # TODO: better to test in InvoiceAttachment
    should 'generate attachment with correct file name' do
      @invoice.provider_account.update_attribute(:org_name, 'YOU')
      @invoice.buyer_account.update_attribute(:org_name, 'ME')
      @invoice.update_attribute(:created_at, Time.zone.local(1984, 1, 31))
      attachment = @generator.generate_as_attachment

      assert_equal 'invoice-january-1984.pdf', attachment.original_filename
      assert_equal 'application/pdf', attachment.content_type
    end

    context "with logo" do
      setup do
        @data.stubs(:has_logo?).returns(true)
        @data.stubs(:logo).returns(LOGO_PICTURE)
        @data.stubs(:provider).returns(LONG_ADDRESS)
      end

      context "and line items" do
	setup do
          items = [ ['Licorice', '5', '222', '' ],
                    ['Haribo  ', '11', '11', '' ],
                    ['Chocolatte', ''  , '11' , ''],
                    ['Sugar', nil  , '11' , ''] ]

          @data.stubs(:line_items).returns(items)
 end

        should 'generate valid PDF content' do
          content = @generator.generate
          # see_in_file(content)
          assert_not_nil content
        end
      end
    end
  end

  private

  # for development purposes
  def see_in_file(content)
    f = File.new('/home/jakub/Desktop/a.pdf','w')
    f << content
    f.close
  end

end
