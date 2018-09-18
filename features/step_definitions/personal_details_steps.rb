# encoding: UTF-8

Then(/^I should see the personal details form$/) do

  should have_css('form#edit_personal_details.formtastic.personal_details')
  within('form#edit_personal_details') do


    should have_xpath('//input[@name="origin" and @type="hidden"]')
    within(:xpath, '//div[@style="margin:0;padding:0;display:inline"]') do

      #
      # correct: ✓
      # incorrect: √
      #
      should have_xpath("//input[@name='utf8' and @type='hidden' and @value='✓']")
      should have_xpath("//input[@name='authenticity_token' and @type='hidden']")
      should have_xpath("//input[@name='_method' and @type='hidden' and @value='put']")
    end
  end

end
