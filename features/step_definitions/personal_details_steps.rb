# frozen_string_literal: true

Then "I should see the personal details form"  do
  should have_css('form#edit_personal_details.formtastic.personal_details')
  within('form#edit_personal_details') do

    should have_xpath('//input[@name="origin" and @type="hidden"]', visible: :hidden)
    within(:xpath, '//div[@style="margin:0;padding:0;display:inline"]') do

      #
      # correct: ✓
      # incorrect: √
      #
      should have_xpath("//input[@name='utf8' and @type='hidden' and @value='✓']", visible: :hidden)
      should have_xpath("//input[@name='authenticity_token' and @type='hidden']", visible: :hidden)
      should have_xpath("//input[@name='_method' and @type='hidden' and @value='put']", visible: :hidden)
    end
  end
end
