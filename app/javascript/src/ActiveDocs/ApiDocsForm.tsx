import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Form,
  PageSection,
  PageSectionVariants,
} from '@patternfly/react-core'

import { NameInput } from 'ActiveDocs/components/NameInput'
import { SystemNameInput } from 'ActiveDocs/components/SystemNameInput'
import { DescriptionInput } from 'ActiveDocs/components/DescriptionInput'

import { CSRFToken } from 'utilities/CSRFToken'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'

interface Props {
  name: string | null;
  systemName: string | null;
  publish: boolean | null;
  description: string | null;
  apiJsonSpec: string | null;
}

const ApiDocsForm: FunctionComponent<Props> = ({
  name,
  systemName,
  publish,
  description,
  apiJsonSpec
}) => {
  const [name, setName] = useState('')
  const [systemName, setSystemName] = useState('')
  const [description, setDescription] = useState('')

  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <Form
          acceptCharset="UTF-8"
          action={url}
          id="new_api_docs"
          method="post"
          onSubmit={() => { setLoading(true) }}
          // isWidthLimited TODO: use when available instead of hardcoded css
        >
          <CSRFToken />
          <input name="utf8" type="hidden" value="✓" />

          <NameInput name={name} setName={setName} />
          <SystemNameInput setSystemName={setSystemName} systemName={systemName} />

          {/* Publish? */}

          <DescriptionInput description={description} setDescription={setDescription} />

          {/* ApiJSONSpec */}

          <ActionGroup>
            <Button
              data-testid="newBackendCreateBackend-buttonSubmit"
              isDisabled={validationErrors !== undefined || isLoading}
              type="submit"
              variant="primary"
            >
              Create backend
            </Button>
          </ActionGroup>
        </Form>
      </PageSection>
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ApiDocsFormWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ApiDocsForm {...props} />, containerId) }

export { ApiDocsForm, ApiDocsFormWrapper, Props }
