import React, { useState } from 'react'
import { useA11yRouteChange, useDocumentTitle } from 'components'
import {
  PageSection,
  TextContent,
  Title,
  Text,
  Card,
  CardBody,
  Button
} from '@patternfly/react-core'

import { useLocalization } from 'i18n'
import * as Locales from 'i18n/locales'
import { ChangeLocaleModal } from 'components/modals/ChangeLocaleModal'

const Overview: React.FunctionComponent = () => {
  const { t, setLocale } = useLocalization('overview')
  const [isModalOpen, setIsModalOpen] = useState(false)

  useA11yRouteChange()
  useDocumentTitle(t('page_title'))

  return (
    <>
      <ChangeLocaleModal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
      <PageSection variant="light">
        <TextContent>
          <p>
            <button type="button" onClick={() => setLocale(Locales.enUS)}>English</button>
            <button type="button" onClick={() => setLocale(Locales.jaJP)}>日本語</button>
          </p>
          <Title size="3xl">{t('body_title')}</Title>
          <Text>
            <b>{ t('subtitle') }</b>
          </Text>
        </TextContent>
      </PageSection>
      <PageSection>
        <Card>
          <CardBody>
            <TextContent>
              <p>{t('greetings')}</p>
              <p>{t('greetings_with_place', { name: 'Juan Doe', place: 'portafly' })}</p>
              <p>{`${t('dates')}:`}</p>
              <p><b>JS Date():</b></p>
              <p>{t('date', { date: Date.now() })}</p>
              <p>{`new Date('2015-03-25'): ${t('date', { date: new Date('2015-03-25') })}`}</p>
              <p><b>{`${t('plurals')}:`}</b></p>
              <ul>
                <li>{t('count_apple', { smart_count: 0 })}</li>
                <li>{t('count_apple', { smart_count: 1 })}</li>
                <li>{t('count_apple', { smart_count: 2 })}</li>
              </ul>
              <p>{t('random_text')}</p>
              <p>
                <Button variant="primary">{ t('cancel_button') }</Button>
                -
                <Button variant="primary">{ t('submit_button') }</Button>
              </p>
              <Button variant="primary" onClick={() => setIsModalOpen(true)}>
                {t('confirm_modal_button.label')}
              </Button>
            </TextContent>
          </CardBody>
        </Card>
      </PageSection>
    </>
  )
}

// eslint-disable-next-line import/no-default-export
export default Overview
