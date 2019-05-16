import jQuery from 'jquery'

export function initialize () {
  jQuery('#cinstance_plan_id')
    .on('change', function () {
      window.createApplication.checkSelectedPlan()
    })
}
