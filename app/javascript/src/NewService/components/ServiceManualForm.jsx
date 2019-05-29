// @flow

import React from 'react'
import {FormWrapper, ServiceManualListItems} from 'NewService/components/FormElements'
import type {FormProps} from 'NewService/types'

const ServiceManualForm = ({formActionPath}: {formActionPath: string}) => {
  const formProps: FormProps = {
    id: 'new_service',
    formActionPath,
    submitText: 'Add API'
  }

  return (
    <FormWrapper {...formProps}>
      <ServiceManualListItems/>
    </FormWrapper>
  )
}

export {
  ServiceManualForm
}
