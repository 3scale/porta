import $ from 'jquery'

export class CreateApplication {
  constructor () {
    this.previewsService = undefined
    this.metadata = $('#metadata-form')
    this.checkSelectedPlan()
  }

  servicePlanNames = () => this.metadata.data('service_plans_names')

  get contractedServices () {
    return this.metadata.data('services_contracted')
  }

  get relationServiceAndServicePlans () {
    return this.metadata.data('relation_service_and_service_plans')
  }

  get relationPlansServices () {
    return this.metadata.data('relation_plans_services')
  }

  getContractedServicePlanForService (service) {
    return this.metadata.data('service_plan_contracted_for_service')[service]
  }

  get selectedPlan () {
    return $('#cinstance_plan_id').val()
  }

  get serviceOfSelectedPlan () {
    return this.relationPlansServices[this.selectedPlan]
  }

  checkSelectedPlan () {
    const service = this.serviceOfSelectedPlan
    const servicePlans = this.relationServiceAndServicePlans[service]

    if (this.previewsService !== service) {
      this.previewsService = service

      this.enableForm()

      if (this.contractedServices.indexOf(service) > -1) {
        const { id, name } = this.getContractedServicePlanForService(service)
        $('#cinstance_service_plan_id').html(`<option value="${id}"> ${name} </option>`)
        $('#cinstance_service_plan_id').attr('disabled', 'disabled')
      } else if (servicePlans.length !== 0) {
        this.setSelectOptions(servicePlans)
      } else {
        $('#cinstance_service_plan_id').html('<option> No service plan for the application plan </option>')
        this.disableForm()
      }
    }
  }

  enableForm () {
    $('#link-help-new-application-service').toggle(false)
    this.enableField('#submit-new-app')
    this.enableField('#cinstance_service_plan_id')
  }

  disableForm (disable) {
    $('#link-help-new-application-service').toggle(true)
    this.disableField('#submit-new-app')
    this.disableField('#cinstance_service_plan_id')
  }

  enableField (field) {
    $(field).removeAttr('disabled')
  }

  disableField (field) {
    $(field).attr('disabled', 'disabled')
  }

  setSelectOptions (servicePlans) {
    let options = ''
    $(servicePlans).each((index, plan) => {
      const selected = plan.default ? 'selected="selected"' : ''
      options += `<option value="${plan.id}" ${selected}>${plan.name}</option>`
    })

    $('#cinstance_service_plan_id').html(options)
    $('#cinstance_service_plan_id').removeAttr('disabled')
  }
}
