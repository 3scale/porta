// @flow

import * as React from 'react'
import {FormWrapper, ServiceManualListItems} from 'NewService/components/FormElements'
import type {FormProps, ServiceFormTemplate} from 'NewService/types'
import type {Api} from 'Types/Api'

type Props = {
  template: ServiceFormTemplate,
  formActionPath: string,
  backendApis: Api[]
}

const ServiceManualForm = (props: Props): React.Node => {
  const {template, formActionPath} = props

  const formProps: FormProps = {
    id: 'new_service',
    formActionPath,
    submitText: 'Create Product'
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
