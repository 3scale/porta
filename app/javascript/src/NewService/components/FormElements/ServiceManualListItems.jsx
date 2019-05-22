// @flow

import React from 'react'
import {Label} from 'NewService/components/FormElements'

const ServiceManualListItems = () =>
  <React.Fragment>
    <li id="service_name_input" className="string required">
      <Label
        htmlFor='service_name'
        label='Name'
        required
      />
      <input maxLength="255" id="service_name" type="text" name="service[name]" autoFocus="autoFocus"/>
    </li>
    <li id="service_system_name_input" className="string required">
      <Label
        htmlFor='service_system_name'
        label='System name'
        required
      />
      <input maxLength="255" id="service_system_name" type="text" name="service[system_name]"/>
      <p className="inline-hints">
        Only ASCII letters, numbers, dashes and underscores are allowed.
      </p>
    </li>
    <li id="service_description_input" className="text optional">
      <Label
        htmlFor='service_description'
        label='Description'
      />
      <textarea rows="3" id="service_description" name="service[description]"></textarea>
    </li>
  </React.Fragment>

export {ServiceManualListItems}
