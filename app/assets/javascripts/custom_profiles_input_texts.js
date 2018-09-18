//TODO dry this out with signup_custom_profiles_input_texts.js code???? maybe not
$(document).ready(
  function() {
    // account profile fields edition
    $('#account_profile_attributes_company_type').change(
      function() {
	//this literal 'Other (please specify)' is also on signup_custom_profiles_input_texts.js
	if ($(this).val() == 'Other (please specify)') {
	  $('#additional_company_type_container').show();
	  $('#account_profile_attributes_additional_company_type').removeAttr("disabled");
	}
	else {
	  $('#additional_company_type_container').hide();
	  $('#account_profile_attributes_additional_company_type').attr("disabled","disabled");
	}
      });

    // user profile fields edition
    $('#user_job_role').change(
      function() {
	if ($(this).val() == 'Other job role') {
	  //this literal 'Other job role' is also on signup_custom_profiles_input_texts.js
	  $('#additional_job_role_container').show();
	  $('#user_additional_job_role').removeAttr("disabled");
	}
	else {
	  $('#additional_job_role_container').hide();
	  $('#user_additional_job_role').attr("disabled","disabled");
	    }
      });
  });
