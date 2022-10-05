/* eslint-disable react/jsx-props-no-spreading */
import { useEffect, useState } from 'react'
import { ErrorMessage, FormWrapper, ServiceDiscoveryListItems } from 'NewService/components/FormElements'
import { fetchData } from 'utilities/fetchData'
import { PROJECTS_PATH } from 'NewService'

import type { FunctionComponent } from 'react'

type Props = {
  formActionPath: string,
  setLoadingProjects: (loading: boolean) => void
}

const ServiceDiscoveryForm: FunctionComponent<Props> = ({
  formActionPath,
  setLoadingProjects
}) => {
  // Don't use named imports so that useState can be mocked in specs
  const [projects, setProjects] = useState<string[]>([])
  const [fetchErrorMessage, setFetchErrorMessage] = useState('')

  const fetchProjects = async () => {
    setLoadingProjects(true)

    try {
      const projects = await fetchData<string[]>(PROJECTS_PATH)
      setProjects(projects)
    } catch (error: any) {
      setFetchErrorMessage(error.message)
    } finally {
      setLoadingProjects(false)
    }
  }

  const listItemsProps = { projects, onError: setFetchErrorMessage } as const

  useEffect(() => {
    fetchProjects()
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

export { ServiceDiscoveryForm, Props }
