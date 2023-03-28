/* eslint-disable react/jsx-props-no-spreading -- FIXME: remove all the spreading */
import { useEffect, useState } from 'react'

import { fetchData } from 'utilities/fetchData'
import { ErrorMessage } from 'NewService/components/FormElements/ErrorMessage'
import { BASE_PATH, ServiceDiscoveryListItems } from 'NewService/components/FormElements/ServiceDiscoveryListItems'
import { FormWrapper } from 'NewService/components/FormElements/FormWrapper'

import type { FunctionComponent } from 'react'

const PROJECTS_PATH = `${BASE_PATH}/projects.json`

interface Props {
  formActionPath: string;
  setLoadingProjects: (loading: boolean) => void;
}

const ServiceDiscoveryForm: FunctionComponent<Props> = ({
  formActionPath,
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

  const formProps = {
    id: 'service_source',
    formActionPath,
    hasHiddenServiceDiscoveryInput: true,
    submitText: 'Create Product'
  } as const

  return (
    <>
      {!!fetchErrorMessage && <ErrorMessage fetchErrorMessage={fetchErrorMessage} />}
      <FormWrapper {...formProps}>
        <ServiceDiscoveryListItems {...listItemsProps} />
      </FormWrapper>
    </>
  )
}

export type { Props }
export { ServiceDiscoveryForm }
