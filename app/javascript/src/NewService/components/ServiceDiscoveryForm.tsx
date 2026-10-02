/* eslint-disable react/jsx-props-no-spreading -- FIXME: remove all the spreading */
import { useEffect, useState } from 'react'
import { Alert, Spinner } from '@patternfly/react-core'

import { fetchData } from 'utilities/fetchData'
import { BASE_PATH, ServiceDiscoveryListItems } from 'NewService/components/FormElements/ServiceDiscoveryListItems'
import { FormWrapper } from 'NewService/components/FormElements/FormWrapper'

import type { FormProps } from 'NewService/types'
import type { FunctionComponent } from 'react'

const PROJECTS_PATH = `${BASE_PATH}/projects.json`

interface Props {
  formActionPath: string;
  loadingProjects: boolean;
  setLoadingProjects: (loading: boolean) => void;
}

const ServiceDiscoveryForm: FunctionComponent<Props> = ({
  formActionPath,
  loadingProjects,
  setLoadingProjects
}) => {
  const [projects, setProjects] = useState<string[]>([])
  const [fetchErrorMessage, setFetchErrorMessage] = useState('')

  const fetchProjects = async () => {
    setLoadingProjects(true)

    try {
      setProjects(await fetchData<string[]>(PROJECTS_PATH))
    } catch (error: unknown) {
      setFetchErrorMessage((error as Error).message)
    } finally {
      setLoadingProjects(false)
    }
  }

  const listItemsProps = { projects, onError: setFetchErrorMessage } as const

  useEffect(() => {
    void fetchProjects()
  }, [])

  const formProps: FormProps = {
    id: 'service_source',
    isSubmitDisabled: loadingProjects || !!fetchErrorMessage,
    formActionPath,
    hasHiddenServiceDiscoveryInput: true,
    submitText: 'Create Product'
  } as const

  return (
    <FormWrapper {...formProps}>
      {!!fetchErrorMessage && <li><Alert isInline title={`Sorry, your request has failed with the error: ${fetchErrorMessage}`} variant="danger" /></li>}
      {loadingProjects && <li><Spinner size="md" /></li>}
      <ServiceDiscoveryListItems {...listItemsProps} />
    </FormWrapper>
  )
}

export type { Props }
export { ServiceDiscoveryForm }
