require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Pdf::Finance::InvoiceReportDataTest < ActiveSupport::TestCase


  def setup
    @provider = FactoryBot.create(:provider_with_billing)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @invoice = FactoryBot.create(:invoice, :provider_account => @provider, :buyer_account => @buyer)
    @data = Pdf::Finance::InvoiceReportData.new(@invoice)
  end

  test 'not change total without VAT rate' do
    @invoice.line_items.create :name => 'Junk', :cost => 42

    assert_equal ["Junk"                     , "", 42 , '' ], @data.line_items[0]
    assert_equal ["Total cost" , "", 42 , 42 ], @data.line_items[1]
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

    assert_equal [ 'Fiscal code', 'chino22' ], @data.buyer[3]
    assert_equal [ 'VAT Code', 'vat55' ], @data.buyer[4]
    assert_equal [ 'PO num', 'po123s' ], @data.buyer[5]

    assert_equal [ [ "Junk", "", 10000.0 , ''],
                   [ "Total cost (without Vat rate)",  "", 10000.0, 10000.0 ],
                   [ "Total Vat rate Amount",  "", 234.0, 234.0 ],
                   [ "Total cost (Vat rate 2.34% included)", "", '', 10234.0 ] ], @data.line_items
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

    assert_equal [ 'Fiscal code', 'chino22' ], @data.buyer[3]
    assert_equal [ 'ABN', 'vat55' ], @data.buyer[4]
    assert_equal [ 'PO num', 'po123s' ], @data.buyer[5]

    assert_equal [ [ "Junk", "", 10000.0 , ''],
                   [ "Total cost (without GST)",  "", 10000.0, 10000.0 ],
                   [ "Total GST Amount",  "", 234.0, 234.0 ],
                   [ "Total cost (GST 2.34% included)", "", '', 10234.0 ] ], @data.line_items
  end


  # Regression test for https://3scale.hoptoadapp.com/errors/7206313
  #
  test 'not be vulnerable to XSS attack' do
    @provider.org_name = '<ScRipT>alert("address1")</ScRipT>'
    assert_equal @data.provider[0][1], '&lt;ScRipT&gt;alert(&quot;address1&quot;)&lt;/ScRipT&gt;'
  end
end
