// @flow

import $ from 'jquery'

type ServicePlan = {
  id: string,
  name: string,
  default: boolean
}

export class CreateApplication {
  previewsService: ?number
  metadata: JQuery

  constructor () {
    this.previewsService = undefined
    this.metadata = $('#metadata-form')

    this.checkSelectedPlan()
  }

  get contractedServices (): number[] {
    return this.metadata.data('services_contracted')
  }

  get relationServiceAndServicePlans (): {[number]: ServicePlan[]} {
    return this.metadata.data('relation_service_and_service_plans')
  }

  getServicePlansForService (serviceId: number): ServicePlan[] {
    return this.relationServiceAndServicePlans[serviceId]
  }

  get relationPlansServices (): {[number]: number} {
    return this.metadata.data('relation_plans_services')
  }

  getContractedServicePlanForService (serviceId: number): ServicePlan {
    return this.metadata.data('service_plan_contracted_for_service')[serviceId]
  }

  get selectedPlan (): number {
    return ($('#cinstance_plan_id').val(): any) // eslint-disable-line flowtype/no-weak-types, casting to number
  }

  get serviceOfSelectedPlan (): number {
    return this.relationPlansServices[this.selectedPlan]
  }

  checkSelectedPlan () {
    const service = this.serviceOfSelectedPlan
    const servicePlans = this.getServicePlansForService(service)

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

  disableForm () {
    $('#link-help-new-application-service').toggle(true)
    this.disableField('#submit-new-app')
    this.disableField('#cinstance_service_plan_id')
  }

  enableField (field: string) {
    $(field).removeAttr('disabled')
  }

  disableField (field: string) {
    $(field).attr('disabled', 'disabled')
  }

  setSelectOptions (servicePlans: ServicePlan[]) {
    let options = ''
    servicePlans.forEach((plan, index) => {
      const selected = plan.default ? 'selected="selected"' : ''
      options += `<option value="${plan.id}" ${selected}>${plan.name}</option>`
    })

    $('#cinstance_service_plan_id').html(options)
    $('#cinstance_service_plan_id').removeAttr('disabled')
  }
}
