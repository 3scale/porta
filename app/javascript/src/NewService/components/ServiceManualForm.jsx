// @flow

import React from 'react'
import {FormWrapper, ServiceManualListItems} from 'NewService/components/FormElements'
import type {FormProps, ServiceFormTemplate} from 'NewService/types'
import type {Api} from 'Types/Api'

type Props = {
  template: ServiceFormTemplate,
  formActionPath: string,
  apiap: boolean,
  backendApis: Api[]
}

const ServiceManualForm = (props: Props) => {
  const {template, formActionPath, apiap} = props

  const formProps: FormProps = {
    id: 'new_service',
    formActionPath,
    submitText: apiap ? 'Create Product' : 'Add API'
  }

  return (
    <FormWrapper {...formProps}>
      <ServiceManualListItems {...template} />
    </FormWrapper>
  )
}

export {
  ServiceManualForm
}
