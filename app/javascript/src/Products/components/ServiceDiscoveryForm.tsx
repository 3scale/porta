/* eslint-disable react/jsx-props-no-spreading -- FIXME: remove all the spreading */
import { useEffect, useState } from 'react'
import {
  ActionGroup,
  Alert,
  Button,
  Form,
  Spinner,
  Stack,
  StackItem
} from '@patternfly/react-core'

import { fetchData } from 'utilities/fetchData'
import { BASE_PATH, ServiceDiscoveryListItems } from 'Products/components/ServiceDiscoveryListItems'
import { CSRFToken } from 'utilities/CSRFToken'

import type { FormProps } from '@patternfly/react-core'
import type { FunctionComponent } from 'react'

const PROJECTS_PATH = `${BASE_PATH}/projects.json`

interface Props extends FormProps {
  loading: boolean;
  setLoadingProjects: (loading: boolean) => void;
}

const ServiceDiscoveryForm: FunctionComponent<Props> = ({
  loading,
  setLoadingProjects,
  ...formProps
}) => {
  const [projects, setProjects] = useState<string[]>([])
  const [fetchErrorMessage, setFetchErrorMessage] = useState('')

  const disabled = (formProps.disabled ?? loading) || !!fetchErrorMessage

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

  useEffect(() => {
    void fetchProjects() // TODO: don't search every time the radio button changes
  }, [])

  return (
    <Stack hasGutter>
      {loading ? (
        <StackItem>
          <Spinner size="lg" />
        </StackItem>
      ) : !!fetchErrorMessage && (
        // TODO: add action "retry" to Alert
        <StackItem>
          <Alert
            isInline
            ouiaId="service-discovery-fetch-error"
            title={`Sorry, your request has failed with the error: ${fetchErrorMessage}`}
            variant="danger"
          />
        </StackItem>
      )}

      <StackItem>
        <Form
          isWidthLimited
          acceptCharset="UTF-8"
          method="post"
          // eslint-disable-next-line react/jsx-props-no-spreading
          {...formProps}
        >
          <input name="utf8" type="hidden" value="✓" />
          <input id="service_source" name="service[source]" type="hidden" value="discover" />
          <CSRFToken />

          <ServiceDiscoveryListItems
            projects={projects}
            onError={setFetchErrorMessage}
          />

          <ActionGroup>
            <Button isDisabled={disabled} type="submit" variant="primary">
              Create Product
            </Button>
          </ActionGroup>
        </Form>
      </StackItem>
    </Stack>
  )
}

export type { Props }
export { ServiceDiscoveryForm }
