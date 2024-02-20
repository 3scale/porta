import $ from 'jquery'
import 'jquery-ui/themes/base/core.css'
import 'jquery-ui/themes/base/sortable.css'
import 'jquery-ui/themes/base/theme.css'
import 'jquery-ui/ui/widgets/sortable'

import { ajax } from 'utilities/ajax'

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.fields-definitions-list.ui-sortable')
    .forEach(list => {
      const $list = $(list)
      $list.sortable({
        update: () => {
          void ajax('/admin/fields_definitions/sort', { method: 'POST', body: $list.sortable('serialize') })
        }
      })
    })
})
