# Examples

Here you can find several examples of liquid usage.

## Legal Terms

    <p>
      By signing up you agree to the following Legal Terms and Conditions
      (<a id="legal-terms-trigger" href="" >show</a>)
    </p>

    <%# REFACTOR: should not be inline! %>
    <div id="legal-terms" style="display:none; overflow-y: scroll; height: 30em;">
      TODO: legal terms text
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
