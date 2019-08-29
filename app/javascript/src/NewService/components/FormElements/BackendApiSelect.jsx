// @flow

import React, {useState} from 'react'
import {Label} from 'NewService/components/FormElements'
import type {Api} from 'Types/Api'

type Props = {
  backendApis: Api[]
}

const BackendApiSelect = ({backendApis}: Props) => {
  const [actAsProduct, setActAsProduct] = useState(false)

  const toggleActAsProduct = (event: SyntheticInputEvent<HTMLInputElement>) => {
    setActAsProduct(event.currentTarget.checked)
  }

  return (
    <React.Fragment>
      <li id="service_act_as_product_input">
        <label htmlFor='act_as_product'>
          <input id="act_as_product" name="service[act_as_product]" type="checkbox" onChange={toggleActAsProduct} />
          Act as product
        </label>
      </li>

      {actAsProduct &&
        <li id="service_backend_api_input">
          <Label
            htmlFor='service_backend_api'
            label='Backend API'
          />
          <select name="service[backend_api]" id="service_backend_api">
            <option key='new' value=''>Create a new Backend API</option>
            {backendApis.map(({id, name}) => <option key={id} value={id}>{name}</option>)}
          </select>
        </li>
      }
    </React.Fragment>
  )
}

export {BackendApiSelect}
