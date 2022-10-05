import type { FunctionComponent } from "react"

type Props = {
  isServiceDiscoveryUsable: boolean,
  serviceDiscoveryAuthenticateUrl: string,
  handleFormsVisibility: (event: React.SyntheticEvent<HTMLInputElement>) => void,
  loadingProjects: boolean
}

const ServiceSourceForm: FunctionComponent<Props> = (props) => {
  const { isServiceDiscoveryUsable, serviceDiscoveryAuthenticateUrl, handleFormsVisibility, loadingProjects } = props
  const classNameDisabled = isServiceDiscoveryUsable ? '' : 'disabled'
  return (
    <form className="formtastic" id="new_service_source">
      <fieldset className="inputs">
        <ol>
          <li className="radio">
            <label htmlFor="source_manual">
              <input
                defaultChecked
                disabled={loadingProjects}
                id="source_manual"
                name="source"
                type="radio"
                value="manual"
                onChange={handleFormsVisibility}
              />
              <span className="new-service-source-input">Define manually</span>
            </label>
          </li>
          <li className="radio">
            <label className={classNameDisabled} htmlFor="source_discover">
              <input
                disabled={!isServiceDiscoveryUsable || loadingProjects}
                id="source_discover"
                name="source"
                type="radio"
                value="discover"
                onChange={handleFormsVisibility}
              />
              <span className="new-service-source-input">Import from OpenShift</span>
              {loadingProjects && <i className="fa fa-spinner fa-spin" />}
              {isServiceDiscoveryUsable || (
                <a href={serviceDiscoveryAuthenticateUrl}>
                  {' (Authenticate to enable this option)'}
                </a>
              )}
            </label>
            <p className="inline-hints">Choosing this option will also create a Backend</p>
          </li>
        </ol>
      </fieldset>
    </form>
  )
}

export { ServiceSourceForm, Props }
