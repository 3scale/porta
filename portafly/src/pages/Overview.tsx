import React from 'react'
import { useTranslation } from 'i18n/useTranslation'
import { useA11yRouteChange, useDocumentTitle } from 'components'
import {
  PageSection,
  TextContent,
  Title,
  Text,
  Card,
  CardBody
} from '@patternfly/react-core'

const Overview: React.FunctionComponent = () => {
  const { t } = useTranslation('overview')
  useA11yRouteChange()
  useDocumentTitle(t('page_title'))
  return (
    <>
      <PageSection variant="light">
        <TextContent>
          <Title size="3xl">{t('body_title')}</Title>
          <Text>
            {t('subtitle')}
          </Text>
        </TextContent>
      </PageSection>
      <PageSection>
        <Card>
          <CardBody>
            <TextContent>
              <p>{t('shared:format.uppercase', { text: 'Ohai' })}</p>
            </TextContent>
          </CardBody>
        </Card>
      </PageSection>
    </>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default Overview
