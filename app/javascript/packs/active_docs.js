// We can define the 3scale plugins here and export the modified bundle
import SwaggerUI from 'swagger-ui'
import { autocompleteOAS3 } from './OAS3Autocomplete'
import 'swagger-ui/dist/swagger-ui.css'
import 'ActiveDocs/swagger-ui-3-patch.scss'

window.autocompleteOAS3 = autocompleteOAS3
window.SwaggerUI = SwaggerUI
