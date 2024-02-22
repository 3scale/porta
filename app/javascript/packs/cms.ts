import jQueryUI from 'jquery'
import 'jquery-ui/ui/widgets/droppable'
import 'jquery-ui/ui/widgets/draggable'
import 'jquery-ui/ui/widgets/tabs'

// Export jQuery 3.7 with jquery-ui widgets to be used in:
// - app/assets/javascripts/provider/admin/cms/intro.js.coffee
// - app/assets/javascripts/provider/admin/cms/templates.js
// - app/assets/javascripts/provider/cms/sidebar.js.coffee
window.jQueryUI = jQueryUI
