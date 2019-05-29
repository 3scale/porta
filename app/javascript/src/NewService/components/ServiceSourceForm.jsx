// @flow

import React from 'react'

type Props = {
  isServiceDiscoveryUsable: boolean,
  serviceDiscoveryAuthenticateUrl: string,
  handleFormsVisibility: (event: SyntheticEvent<HTMLInputElement>) => void
}

const ServiceSourceForm = (props: Props) => {
  const {isServiceDiscoveryUsable, serviceDiscoveryAuthenticateUrl,
    handleFormsVisibility} = props
  const classNameDisabled = isServiceDiscoveryUsable ? '' : 'disabled'
  return (
    <form className="formtastic" id="new_service_source">
      <fieldset className="inputs">
        <ol>
          <li className="radio">
            <label htmlFor="source_manual">
              <input type="radio" name="source" id="source_manual" value="manual" defaultChecked="defaultChecked" onChange={handleFormsVisibility}/>
              <span className="new-service-source-input">Define manually</span>
            </label>
          </li>
          <li className="radio">
            <label htmlFor="source_discover"
              className={classNameDisabled}>
              <input type="radio" name="source" id="source_discover" value="discover" disabled={!isServiceDiscoveryUsable} onChange={handleFormsVisibility}/>
              <span className="new-service-source-input">Import from OpenShift</span>
              { isServiceDiscoveryUsable ||
                <a href={serviceDiscoveryAuthenticateUrl}>
                  {' (Authenticate to enable this option)'}
                </a>
              }
            </label>
          </li>
        </ol>
      </fieldset>
    </form>
  )
}

export {
  ServiceSourceForm
}
