module JsModuleLoaderHelper

  def render_js_module_loader
    javascript_include_tag('system.js') + javascript_include_tag('jspm.js')
  end
end
