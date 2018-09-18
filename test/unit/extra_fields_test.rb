require 'test_helper'


class ExtraFieldsTest < ActiveSupport::TestCase

  setup do
    @provider = Factory :provider_account
    @buyer = Factory :buyer_account, :provider_account => @provider

    Factory(:fields_definition, :account => @provider, :target => "Account",
            :name => "provider_extra_field", :required => true)
    Factory(:fields_definition, :account => Account.master,
            :target => "Account",
            :name => "master_extra_field", :required => true)

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

    refute @buyer.valid?
    assert_not_empty @buyer.errors["provider_extra_field"]
  end

  test 'to_xml renders extra_fields' do
    Factory(:fields_definition,
            account: @provider,
            target: "Account",
            name: "stuff",
            choices: ["Orange", "Apple", "Banana"])
    @buyer.reload
    @buyer.extra_fields = { "stuff"=> "Apple" }
    doc = Nokogiri::XML.parse(@buyer.to_xml)

    assert_equal 1, doc.xpath('//extra_fields/stuff').size
    assert_equal 'Apple', doc.xpath('//extra_fields/stuff').first.text
  end

  # Regression test for https://github.com/3scale/system/issues/2752
  test 'to_xml works with multiple valued extra field' do
    Factory(:fields_definition,
            account: @provider,
            target: "Account",
            name: "stuff",
            choices: ["Orange", "Apple", "Banana"])
    @buyer.reload
    @buyer.extra_fields = { "stuff"=>["Apple", "Orange"] }

    doc = Nokogiri::XML.parse(@buyer.to_xml)
    assert_equal ['Apple', 'Orange'], doc.xpath('//extra_fields/stuff').map(&:text)
  end


  # TODO: make it independent on Account model
  # TODO: remove the shoulda forest
  context 'extra fields' do
    context 'validations' do
      should 'never be done for provider resource' do
        @provider.extra_fields = { :provider_extra_field => nil }
        @provider.validate_fields!
        User.current = @provider.admins.first

        assert @provider.valid?
      end

      should 'never be done for master resource' do
        master = Account.master
        master.extra_fields = { :master_extra_field => nil }
        master.validate_fields!
        User.current = Account.master.admins.first

        assert master.extra_fields[:master_extra_field].nil?
        assert master.valid?
      end
    end # validations

    context 'setters' do
      should 'set key value defined in FieldsDefinition' do
        expected = @buyer.extra_fields = { :provider_extra_field => "is set" }
        @buyer.save!
        assert_equal expected, @buyer.extra_fields
      end

      should 'not set key value not defined in FieldsDefinition' do
        @buyer.extra_fields = { :non_existant => "is set" }
        @buyer.save!
        assert @buyer.extra_fields.empty?
      end

      #beware of this!!!
      # should 'not set key value not defined in FieldsDefinition using [] notation' do
      #   @buyer[:extra_fields][:hack] = "attack"
      #   @buyer.save!
      #   assert @buyer.extra_fields[:hack].nil?
      # end

      should 'not remove already set extra_fields' do
        bar_field = Factory(:fields_definition, :account => @provider,
                            :target => "Account", :name => "deleted_field")
        @buyer.reload
        expected = @buyer.extra_fields = { :deleted_field => "exists yet" }
        @buyer.save!
        bar_field.destroy

        @buyer.extra_fields = { :provider_extra_field => "bar" }
        @buyer.save!
        assert_equal 'exists yet', @buyer.extra_fields[:deleted_field]
      end

      should 'override using [] notation' do
        @buyer.extra_fields = { :provider_extra_field => "[] notation overridable" }
        @buyer.save!

        @buyer[:extra_fields] = { }
        @buyer.save!
        assert @buyer.extra_fields.empty?
      end

      should 'force encoding on strings' do
        @buyer.extra_fields = {
          provider_extra_field: "\xD0\xBF\xD0\xBE\xD0\xBA\xD0\xB0\xD0\xB7\xD1\x8B\xD0\xB2\xD0\xB0\xD1\x82\xD1\x8C \xD0\xBD\xD0\xB0 \xD0\xB1\xD0\xB5\xD1\x81\xD0\xBF\xD0\xBB\xD0\xB0\xD1\x82\xD0\xBD\xD0\xBE\xD0\xBC \xD0\xBF\xD1\x80\xD0\xB8\xD0\xBB\xD0\xBE\xD0\xB6\xD0\xB5\xD0\xBD\xD0\xB8\xD0\xB8 \xD1\x82\xD0\xB0\xD0\xB1\xD0\xBB\xD0\xBE \xD0\xB2\xD1\x8B\xD0\xBB\xD0\xB5\xD1\x82\xD0\xBE\xD0\xB2 \xD1\x81\xD0\xB0\xD0\xBC\xD0\xBE\xD0\xBB\xD0\xB5\xD1\x82\xD0\xBE\xD0\xB2".force_encoding('BINARY')
        }

        str = @buyer.extra_fields[:provider_extra_field]

        assert_equal Encoding.default_internal, str.encoding
      end

      should 'force encoding on the getter' do
        @buyer.extra_fields[:provider_extra_field] = "\xD0\xBF\xD0\xBE\xD0\xBA\xD0\xB0\xD0\xB7\xD1\x8B\xD0\xB2\xD0\xB0\xD1\x82\xD1\x8C \xD0\xBD\xD0\xB0 \xD0\xB1\xD0\xB5\xD1\x81\xD0\xBF\xD0\xBB\xD0\xB0\xD1\x82\xD0\xBD\xD0\xBE\xD0\xBC \xD0\xBF\xD1\x80\xD0\xB8\xD0\xBB\xD0\xBE\xD0\xB6\xD0\xB5\xD0\xBD\xD0\xB8\xD0\xB8 \xD1\x82\xD0\xB0\xD0\xB1\xD0\xBB\xD0\xBE \xD0\xB2\xD1\x8B\xD0\xBB\xD0\xB5\xD1\x82\xD0\xBE\xD0\xB2 \xD1\x81\xD0\xB0\xD0\xBC\xD0\xBE\xD0\xBB\xD0\xB5\xD1\x82\xD0\xBE\xD0\xB2".force_encoding('BINARY')

        str = @buyer.extra_fields[:provider_extra_field]

        assert_equal Encoding.default_internal, str.encoding
      end
    end # setters

  end # extra fields

  context 'fields definitions' do
    #TODO: do this test in user and cinstance also or find a way of doing
    # shared_examples
    setup do
      @provider = Factory :provider_account

      @provider_field = Account.optional_fields.first
      @master_field = Account.optional_fields.last

      @buyer = Factory(:buyer_account, :provider_account => @provider,
                       @provider_field => "") # <= this won't be needed when accounts.org_legaladdress can be null in db

      Factory(:fields_definition, :account => Account.master,
              :target => "Account", :name => @master_field, :required => true)
      Factory(:fields_definition, :account => @provider, :target => "Account",
              :name => @provider_field, :required => true)

      @provider.reload
      @buyer.reload
    end

    context 'fields methods' do
      setup do
        Factory(:fields_definition, :account => @provider,
                :target => "Account", :name => "extra_field", :required => true)
      end

      should '#defined_builtin_fields not include extra fields' do
        assert @buyer.defined_builtin_fields.map(&:name).exclude?("extra_field")
      end

      should '#fields_to_xml not include extra fields' do
        @buyer.send "#{@provider_field}=", "builtin"
        @buyer.extra_fields = { "extra_field" => "extra_field" }
        @buyer.save!
        xml = Builder::XmlMarkup.new

        @buyer.fields_to_xml(xml)
        assert xml.to_s !~ /extra_field/
      end
    end

    context 'validations' do

      context 'buyer resource' do

        should 'not be done by default' do
          assert @buyer.valid?
          assert @buyer.errors[@provider_field].empty?
        end

        should 'be done if said so' do
          @buyer.validate_fields!

          assert false == @buyer.valid?
          assert @buyer.errors[@provider_field].present?
        end

        context 'choices fields' do
          setup do
            #OPTIMIZE: better would be not to have this here by rewriting the tests
            @buyer.reload
            Factory(:fields_definition,
                    :account => @provider,
                    :target => "Account",
                    :name => "city",
                    :required => true,
                    :choices => ["Vic", "Avia"])
            @buyer.attributes = { @provider_field => "avoiding errors on other field" }
          end

          should 'be invalid if value is not allowed' do
            @buyer.city = "Solsona"
            @buyer.validate_fields!
            refute @buyer.valid?
            assert_not_empty @buyer.errors["city"]
          end

          should 'be valid if value is allowed' do
            @buyer.city = "Vic"
            @buyer.validate_fields!
            assert @buyer.valid?
          end
        end # choices fields

      end # buyer resource

      should 'never be done for provider resource' do
        @provider.send "#{@provider_field}=", nil
        @provider.validate_fields!

        assert @provider.field_value(@provider_field).nil?
        assert @provider.valid?
      end

      should 'never be done for master resource' do
        master = Account.master
        master.send "#{@master_field}=", nil
        master.validate_fields!

        assert master.field_value(@master_field).nil?
        assert master.valid?
      end

    end # validations

    context 'source' do
      should 'be provider fields for existing providers' do
        @provider.send "#{@master_field}=", nil
        @provider.validate_fields!

        assert @provider.valid?
      end

      should 'be master fields for new providers' do
        new_provider = Factory.build :provider_account
        assert new_provider.defined_fields.map(&:name).include?(@master_field)
      end
    end # source

    context 'required fields' do
      should 'be created automatically for provider' do
        provider = Factory.build :provider_account
        provider.save

        assert provider.fields_definitions.present?
        assert provider.fields_definitions.all? { |f| f.required? }
      end
    end # required fields

  end # fields definitions
end
