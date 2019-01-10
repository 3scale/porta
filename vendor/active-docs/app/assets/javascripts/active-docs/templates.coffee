templates  =

  backbone: """
  <div id='apidocs-resources-container'>
    <h2>Operations</h2>
    <ul id='apidocs-resources'></ul>
  </div>
  <div class='apidocs-param-tips apidocs-signin-message' style='display:none;'>
    <p><a href='#'>Sign in</a> to your account for quick access to useful values.</p>
  </div>
  <div class='apidocs-param-tips apidocs-nothere-message' style='display:none;'>
    <p>
    Please view ActiveDocs from your API Admin Portal <br />
    <strong>OR</strong> <br />
    <a class='big-button' href='http://www.3scale.net'><small>CREATE YOUR</small> <br /> Free Account</a>
    </p>
  </div>
  """

  paramTemplate: """
  <tr class='zebra'>
    <td class='{{if required}}required{{/if}}'>${name}</td>
    <td>
      <input

        {{if required}}
          placeholder='(required)'
          class='required'
        {{/if}}

        {{if encode}}
          data-encode='true'
        {{/if}}

        {{if threescale_name }}
          data-threescale-name='${threescale_name}'
        {{/if}}

        data-guid='${guid}'
        data-param-type='${paramType}'
        minlength='0'
        name='${name}'
        data-original-name='${name}'
        type='text'
        value='${defaultValue}'>
        <div class='apidocs-description'>
          ${description_inline}
        </div>
    </td>
    <td>
      <div class='apidocs-description'>
        ${description}
      </div>
    </td>
  </tr>
  """

  paramTemplateBody: """
  <tr class='zebra'>
    <td class='{{if required}}required{{/if}}'>${name}</td>
    <td>
      <textarea

        {{if required}}
          placeholder='(required)'
          class='required'
        {{/if}}

        {{if threescale_name }}
          data-threescale-name='${threescale_name}'
        {{/if}}

        data-guid='${guid}'
        data-param-type='body'
        name='${name}'
        data-original-name='${name}'>${defaultValue}</textarea>

        <div class='apidocs-description'>
          ${description_inline}
        </div>
    </td>
    <td>
      <div class='apidocs-description'>
        ${description}
      </div>
    </td>
  </tr>
  """

  paramTemplateCustom: """
  <tr class='zebra'>
    <td class='code'>${name} {{if allowMultiple }} <a class='add' href='#' data-guid='${guid}'>&nbsp;</a> {{/if}}</td>
    <td>
      <input class='custom name' {{if threescale_name }}data-threescale-name='${threescale_name}'{{/if}} data-param-type='custom'  minlength='0' name='${name}' placeholder='name' type='text' value='${defaultName}' />
      <input class='custom value' data-param-type='custom'  minlength='0' name='${name}' placeholder='value' type='text' value='${defaultValue}' />
      <input class='custom-hidden'  data-guid='${guid}' data-param-type='${paramType}' name='${name}' type='hidden' data-original-name='' value='' />
     <div class='apidocs-description'>
        ${description_inline}
      </div
    </td>
    <td>
     <div class='apidocs-description'>
       ${description}
     </div>
    </td>
  </tr>
  """

  paramTemplateArray: """
  <tr class='zebra' data-name='${name}' data-count='0' data-parent='true' data-data-type='${dataType}'>
    <td class='code'>${name} {{if allowMultiple }} <a class='add' href='#' data-guid='${guid}'>&nbsp;</a> {{/if}}</td>
    <td>
      <table>
        <thead>
          <tr>
            <th>Parameter</th>
            <th>Value</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody data-param-type='${paramType}' data-count='0' data-data-type='${dataType}' id='${template_id}' data-parent='true' data-guid='${guid}' data-name='${name}'>
        </tbody>
      </table>
    </td>
    <td>
      <div class='apidocs-description'>
        ${description}
      </div>
    </td>
  </tr>
  """

  ##
  # Very nasty hack:
  #
  # if user does not specify defaultValue of required in parameter definition
  # and it is a list, then it tries to lookup undefined variable
  # (because jquery.tmpl compiles templates in a bad way)
  #
  # so $data is internal variable of item passed to template
  # accessing it's inexistent attribute will not throw exception

  paramTemplateSelect: """
  <tr>
    <td class='code'>${name}</td>
    <td>
      <select name='${name}' data-param-type='${paramType}' data-original-name='${name}'>
        {{if required == false }}
        <option selected='selected' value=''></option>
        {{/if}}
        {{each allowableValues.values}}
        {{if $value == $data.defaultValue && $data.required == true}}
        <option selected='selected' value='${$value}'>${$value}</option>
        {{else}}
        <option value='${$value}'>${$value}</option>
        {{/if}}
        {{/each}}
      </select>
    </td>
    <td>${description}</td>
  </tr>
  """

  resourceTemplate: """
  <li class='resource' id='resource_${name}'>
    <div class='apidocs-heading operation-heading'>
      <h2>
        <a data-name='${name}' href='#/${name}'>${friendly_name}</a>
      </h2>
    </div>
    <ul class='endpoints' id='${name}_endpoint_list' style=''></ul>
  </li>
  """

  apiTemplate: """
  <li class='endpoint'>
    <ul class='operations' id='${name}_endpoint_operations'></ul>
  </li>
  """

  operationTemplate: """
  <li class='${httpMethodLowercase} operation' data-operation-id='${guid}'>
    <div class='apidocs-heading' style='background-color:${groupColour}'>
      <div class='apidocs-bubble'>
        <div class='action'>
          <a class='toggle'>${summary}</a>
        </div>
      </div>
      <div class='path-and-method'>
        <span class='path'><a>${path}</a></span>
        <span class='http_method'><a>${httpMethod}</a></span>
      </div>
      <ul class='options' style='display:none'>
        <li>
          <a>${path}</a>
        </li>
      </ul>
    </div>
    <div class='content' data-operation-id='${guid}' style='display:none'>
      {{if description}}
      <h4>Description</h4>
      <p>{{html description}}</p>
      {{/if}}
      {{if notes}}
      <h4>Implementation Notes</h4>
      <p>{{html notes}}</p>
      {{/if}}
      <form accept-charset='UTF-8' data-method='${httpMethod}' data-host='${basePath}' data-path='${path}' action='#' class='sandbox' method='post'>
        <div style='margin:0;padding:0;display:inline'></div>
        <table class='fullwidth'>
          <thead>
            <tr>
              <th>Parameter</th>
              <th>Value</th>
              <th>Description</th>
            </tr>
          </thead>
          <tbody id='${apiName}_${guid}_${httpMethod}_params'></tbody>
        </table>
        <div class='submit-bar'>
          {{if permitted}}
            <button class='submit' name='commit' type='button'>
            <span>Send Request</span>
          </button>
          {{/if}}
          <a href='#' data-guid='${guid}' class='hide-response' style='display:none;'>HIDE RESPONSE</a>
        </div>
      </form>
      <div class='response' data-guid='${guid}' style='display:none'>

        <h4 class='request_heading'>Request</h4>
        <div class='block request_url'><pre class='prettyprint'></pre></div>

        <h4 class='response_body_heading'>Response Body</h4>
        <div class='block response_body'><pre class='prettyprint'></pre></div>

        <h4>Response Code</h4>
        <div class='block response_code'><pre></pre></div>

        <h4>Response Headers</h4>
        <div class='block response_headers'><pre class='prettyprint'></pre></div>

      </div>
    </div>
  </li>
  """

  paramTips: """
  <div class='apidocs-param-tips ${type}' style='display:none;'>
      <p class='apidocs-tip-description'>${description}</p>
      <ul>
        {{each items}}
        <li data-value='${value}'><strong>${name}</strong> <span>${value}</span></li>
        {{/each}}
      </ul>
  </div>
  """

ThreeScale.APIDocs.templates = templates
