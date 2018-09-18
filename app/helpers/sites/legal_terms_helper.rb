module Sites::LegalTermsHelper

  def insert_legal_terms_snippet_button
   legal_term_snippet = <<-SNIPPET
     <p>
       By signing up you agree to the following Legal Terms and Conditions
       (<a id="legal-terms-trigger" href="" >show</a>)
     </p>

     <div id="legal-terms" style="display:none; overflow-y: scroll; height: 30em;">
        <!--
           -
           -
           -
           -  PUT YOUR TERMS & CONDITIONS HERE
           -
           -
           -
         -->
     </div>

     <script type="text/javascript">
     //<![CDATA[
         $('#legal-terms-trigger').toggle(
           function() {
             $('#legal-terms').fadeIn();
             $('#legal-terms-trigger').text('hide');
           },
           function() {
             $('#legal-terms').fadeOut();
             $('#legal-terms-trigger').text('show');
           }
          );
     //]]>
     </script>
    SNIPPET

    escaped_snippet = legal_term_snippet.strip_heredoc.to_json
    js = "$('#cms_template_draft').data('codemirror').setValue(#{escaped_snippet});"

    link_to 'Insert toggling code', '#', onclick: js, class: 'less-important-button'
  end

  def edit_legal_terms_url(system_name)
    legal_term = current_account.builtin_partials.find_by_system_name(system_name)

    if legal_term
      edit_provider_admin_cms_builtin_legal_term_path(legal_term)
    else
      new_provider_admin_cms_builtin_legal_term_path(system_name: system_name)
    end
  end

  def edit_legal_terms_link(system_name)
    title = t("builtin_legal_terms.#{system_name}.menu_title")
    sidebar_link title, edit_legal_terms_url(system_name)
  end

end
