import $ from 'jquery'
import 'jquery-ui/themes/base/core.css'
import 'jquery-ui/themes/base/sortable.css'
import 'jquery-ui/themes/base/theme.css'
import 'jquery-ui/ui/widgets/sortable'

import { ajax } from 'utilities/ajax'
import { toast } from 'utilities/toast'

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('ul.ui-sortable')
    .forEach(list => {
      const $list = $(list) as WithRequiredProp<JQuery, 'sortable'> // imported in this file
      $list.sortable({
        cancel: '', // This allows <button> to trigger the sorting.
        cursor: 'grabbing',
        handle: '.pf-c-data-list__item-draggable-button',
        helper: 'clone',
        items: '> .pf-c-data-list__item',
        update: () => {
          $list.sortable('disable')
          ajax('/admin/fields_definitions/sort', { method: 'POST', body: $list.sortable('serialize') })
            .catch(() => {
              toast('Something went wrong', 'danger')
            })
            .finally(() => {
              $list.sortable('enable')
            })
        }
      })
    })
})
