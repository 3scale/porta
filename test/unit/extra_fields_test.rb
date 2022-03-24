require 'test_helper' # rubocop:disable Style/FrozenStringLiteralComment

class ExtraFieldsTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)

    @provider.reload
    @buyer.reload
  end

  class FieldsDefinitionTest < ExtraFieldsTest

    def setup
      super

      @provider_field = Account.optional_fields.first
      @master_field = Account.optional_fields.last

      @buyer.update!({@provider_field => ''}) # this won't be needed when accounts.org_legaladdress can be null in db

      FactoryBot.create(:fields_definition, account: @provider, target: 'Account', name: 'provider_extra_field', required: true)
      FactoryBot.create(:fields_definition, account: master_account, target: 'Account', name: 'master_extra_field', required: true)

      FactoryBot.create(:fields_definition, account: @provider, target: 'Account', name: @provider_field, required: true)
      FactoryBot.create(:fields_definition, account: master_account, target: 'Account', name: @master_field, required: true)

      @provider.reload
      @buyer.reload
    end

    test 'extra_fields not validated by default' do
      assert @buyer.valid?
    end

    test '#validate_fields!' do
      # extra fields are validated on demand only
      @buyer.validate_fields!
      User.current = @buyer.admins.first

      assert_not @buyer.valid?
      assert_not_empty @buyer.errors['provider_extra_field']
    end

    test 'never be done for provider resource' do
      @provider.extra_fields = { provider_extra_field: nil }
      @provider.validate_fields!
      User.current = @provider.admins.first

      assert @provider.valid?
    end

    test 'never be done for master resource' do
      master_account.extra_fields = { master_extra_field: nil }
      master_account.validate_fields!
      User.current = master_account.admins.first!

      assert master_account.extra_fields[:master_extra_field].nil?
      assert master_account.valid?
    end

    test 'set key value defined in FieldsDefinition' do
      expected = @buyer.extra_fields = { provider_extra_field: 'is set' }
      @buyer.save!
      assert_equal expected, @buyer.extra_fields
    end

    test 'not set key value not defined in FieldsDefinition' do
      @buyer.extra_fields = { non_existant: 'is set' }
      @buyer.save!
      assert @buyer.extra_fields.empty?
    end

    test 'not remove already set extra_fields' do
      bar_field = FactoryBot.create(:fields_definition, account: @provider, target: 'Account', name: 'deleted_field')
      @buyer.reload
      @buyer.extra_fields = { deleted_field: 'exists yet' }
      @buyer.save!
      bar_field.destroy

      @buyer.extra_fields = { provider_extra_field: 'bar' }
      @buyer.save!
      assert_equal 'exists yet', @buyer.extra_fields[:deleted_field]
    end

    test 'override using [] notation' do
      @buyer.extra_fields = { provider_extra_field: '[] notation overridable' }
      @buyer.save!

      @buyer[:extra_fields] = { }
      @buyer.save!
      assert @buyer.extra_fields.empty?
    end

    test 'force encoding on strings' do
      @buyer.extra_fields = {
        provider_extra_field: "\xD0\xBF\xD0\xBE\xD0\xBA\xD0\xB0\xD0\xB7\xD1\x8B\xD0\xB2\xD0\xB0\xD1\x82\xD1\x8C \xD0\xBD\xD0\xB0 \xD0\xB1\xD0\xB5\xD1\x81\xD0\xBF\xD0\xBB\xD0\xB0\xD1\x82\xD0\xBD\xD0\xBE\xD0\xBC \xD0\xBF\xD1\x80\xD0\xB8\xD0\xBB\xD0\xBE\xD0\xB6\xD0\xB5\xD0\xBD\xD0\xB8\xD0\xB8 \xD1\x82\xD0\xB0\xD0\xB1\xD0\xBB\xD0\xBE \xD0\xB2\xD1\x8B\xD0\xBB\xD0\xB5\xD1\x82\xD0\xBE\xD0\xB2 \xD1\x81\xD0\xB0\xD0\xBC\xD0\xBE\xD0\xBB\xD0\xB5\xD1\x82\xD0\xBE\xD0\xB2".force_encoding('BINARY')
      }

      str = @buyer.extra_fields[:provider_extra_field]

      assert_equal Encoding.default_internal, str.encoding
    end

    test 'force encoding on the getter' do
      @buyer.extra_fields[:provider_extra_field] = "\xD0\xBF\xD0\xBE\xD0\xBA\xD0\xB0\xD0\xB7\xD1\x8B\xD0\xB2\xD0\xB0\xD1\x82\xD1\x8C \xD0\xBD\xD0\xB0 \xD0\xB1\xD0\xB5\xD1\x81\xD0\xBF\xD0\xBB\xD0\xB0\xD1\x82\xD0\xBD\xD0\xBE\xD0\xBC \xD0\xBF\xD1\x80\xD0\xB8\xD0\xBB\xD0\xBE\xD0\xB6\xD0\xB5\xD0\xBD\xD0\xB8\xD0\xB8 \xD1\x82\xD0\xB0\xD0\xB1\xD0\xBB\xD0\xBE \xD0\xB2\xD1\x8B\xD0\xBB\xD0\xB5\xD1\x82\xD0\xBE\xD0\xB2 \xD1\x81\xD0\xB0\xD0\xBC\xD0\xBE\xD0\xBB\xD0\xB5\xD1\x82\xD0\xBE\xD0\xB2".force_encoding('BINARY')

      str = @buyer.extra_fields[:provider_extra_field]

      assert_equal Encoding.default_internal, str.encoding
    end

    test 'FieldsMethods #defined_builtin_fields not include extra fields' do
      FactoryBot.create(:fields_definition, account: @provider, target: 'Account', name: 'extra_field', required: true)

      assert @buyer.defined_builtin_fields.map(&:name).exclude?('extra_field')
    end

    test 'FieldsMethods #fields_to_xml not include extra fields' do
      FactoryBot.create(:fields_definition, account: @provider, target: 'Account', name: 'extra_field', required: true)

      @buyer.send "#{@provider_field}=", 'builtin'
      @buyer.extra_fields = { 'extra_field' => 'extra_field' }
      @buyer.save!
      xml = Builder::XmlMarkup.new

      @buyer.fields_to_xml(xml)
      assert xml.to_s !~ /extra_field/
    end

    test 'Source be provider fields for existing providers' do
      @provider.send "#{@master_field}=", nil
      @provider.validate_fields!
      assert @provider.valid?

    end

    test 'Source be master fields for new providers' do
      new_provider = FactoryBot.build(:provider_account)
      assert new_provider.defined_fields.map(&:name).include?(@master_field)
    end

    test 'RequiredFields be created automatically for provider' do
      provider = FactoryBot.create(:provider_account)

      assert provider.fields_definitions.present?
      assert provider.fields_definitions.all?(&:required?)
    end

    test 'Validations never be done for provider resource' do
      @provider.send "#{@provider_field}=", nil
      @provider.validate_fields!

      assert @provider.field_value(@provider_field).nil?
      assert @provider.valid?
    end

    test 'Validations never be done for master resource' do
      master_account.send "#{@master_field}=", nil
      master_account.validate_fields!

      assert master_account.field_value(@master_field).nil?
      assert master_account.valid?
    end

    test 'Validations BuyerResource resource not be done by default' do
      assert @buyer.valid?
      assert @buyer.errors[@provider_field].empty?
    end

    test 'Validations BuyerResource resource be done if said so' do
      @buyer.validate_fields!

      assert_not @buyer.valid?
      assert @buyer.errors[@provider_field].present?
    end

    # Regression: https://app.bugsnag.com/3scale-networks-sl/system/errors/61eefe2bd365260008097f85
    test 'extra_field should not be store as an integer' do
      @buyer.extra_fields = { provider_extra_field: 5 }
      @buyer.save!

      assert_equal '5', @buyer.extra_fields[:provider_extra_field]
      assert @buyer.to_xml
    end
  end

  class ChoicesFieldsTest < ExtraFieldsTest

    def setup
      super
      FactoryBot.create(:fields_definition, account: @provider, target: 'Account', name: 'city', required: true, choices: %w[Vic Avia Barna])
      FactoryBot.create(:fields_definition, account: @provider, target: 'Account', name: 'stuff', choices: %w[Orange Apple Banana])
    end

    test 'be invalid if value is not allowed' do
      @buyer.city = 'Solsona'
      @buyer.validate_fields!
      assert_not @buyer.valid?
      assert_not_empty @buyer.errors['city']
    end

    test 'be valid if value is allowed' do
      @buyer.city = 'Vic'
      @buyer.validate_fields!
      assert @buyer.valid?
    end

    test '#to_xml renders extra_fields' do
      @buyer.extra_fields = { 'stuff' => 'Apple' }
      doc = Nokogiri::XML.parse(@buyer.to_xml)

      assert_equal 1, doc.xpath('//extra_fields/stuff').size
      assert_equal 'Apple', doc.xpath('//extra_fields/stuff').first.text
    end

    # Regression test for https://github.com/3scale/system/issues/2752
    test '#to_xml works with multiple valued extra field' do
      @buyer.extra_fields = { 'stuff' => %w[Apple Orange] }

      doc = Nokogiri::XML.parse(@buyer.to_xml)
      assert_equal %w[Apple Orange], doc.xpath('//extra_fields/stuff').map(&:text)
    end

    # Regression: https://app.bugsnag.com/3scale-networks-sl/system/errors/61eefe2bd365260008097f85
    test '#to_xml works with numeric values' do
      @buyer.extra_fields = { 'stuff' => 4 }
      doc = Nokogiri::XML.parse(@buyer.to_xml)
      assert_equal 1, doc.xpath('//extra_fields/stuff').size
      assert_equal '4', doc.xpath('//extra_fields/stuff').first.text

      @buyer.extra_fields = { 'stuff' => [1, 2] }
      doc = Nokogiri::XML.parse(@buyer.to_xml)
      assert_equal %w[1 2], doc.xpath('//extra_fields/stuff').map(&:text)
    end
  end
end
