
/* eslint-disable camelcase */
export type ServiceFormTemplate = {
  service: {
    name: string,
    system_name: string,
    description: string
  },
  errors: {
    name?: string[],
    system_name?: string[],
    description?: string[]
  }
}
/* eslint-enable camelcase */

export type FormProps = {
  id: string,
  formActionPath: string,
  hasHiddenServiceDiscoveryInput?: boolean,
  submitText: string,
  children?: React.ReactNode
}
