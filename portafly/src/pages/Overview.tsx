import React, { useState, useContext } from 'react'
import {useA11yRouteChange, useDocumentTitle} from 'components'
import {
  PageSection,
  TextContent,
  Title,
  Text,
  Card,
  CardBody,
  Modal,
  Button
} from '@patternfly/react-core'

import moment from 'moment'
import { I18nContext } from 'i18n/I18nProvider'
import { 
  OVERVIEW as STRINGS_ENG,
  COMMONS as COMMONS_ENG
} from 'i18n/locales/en/strings'
import { 
  OVERVIEW as STRINGS_JAP,
  COMMONS as COMMONS_JAP
} from 'i18n/locales/jp/strings'

const Overview: React.FunctionComponent = ({children}) => {
  const [strings, setStrings] = useState(STRINGS_ENG)
  const [commonStrings, setCommonStrings] = useState(COMMONS_ENG)
  const [locale, setLocale] = useState('en')
  const polyglot = useContext(I18nContext)
  polyglot.locale(locale)  
  polyglot.extend({ ...strings, ...commonStrings })

  const onClick = (event: React.SyntheticEvent<HTMLButtonElement>) => {
    setStrings(event.currentTarget.value === 'en' ? STRINGS_ENG : STRINGS_JAP)
    setCommonStrings(event.currentTarget.value === 'en' ? COMMONS_ENG : COMMONS_JAP)
    setLocale(event.currentTarget.value)
  }

  useA11yRouteChange()
  useDocumentTitle(polyglot.t('page_title'))
  return (
    <>
      <PageSection variant={'light'}>
        <TextContent>
          <p>
            <button value='en' onClick={onClick}>English</button>
            <button value='jp' onClick={onClick}>日本語</button>
          </p>
          <Title size={'3xl'}>{polyglot.t('body_title')}</Title>
          <Text>
          <b>{polyglot.t('subtitle')}</b>     
          </Text>
        </TextContent>
      </PageSection>
      <PageSection>
        <Card>
          <CardBody>
            <TextContent>
              <p>{polyglot.t('greetings')}</p>
              <p>
                {polyglot.t('greetings_with_place', { 
                  name: 'Juan Doe',
                  place: 'portafly'
                })}
              </p>
              <p>{polyglot.t('dates')}:</p>
              <p>Date.now(): { polyglot.t('date', { date: Date.now() }) }</p>
              <p>new Date('2015-03-25'): { polyglot.t('date', { date: new Date('2015-03-25') }) }</p>
              <p>moment(): { polyglot.t('date', { date: moment() }) }</p>
              <p>moment('1995-12-25'):  { polyglot.t('date', { date: moment('1995-12-25') }) }</p>
              <p>{polyglot.t('plurals')}:</p>
              <ul>
                <li>{ polyglot.t('count_apple', { smart_count: 0 }) }</li>
                <li>{ polyglot.t('count_apple', { smart_count: 1 }) }</li>
                <li>{ polyglot.t('count_apple', { smart_count: 2 }) }</li>
              </ul>
              <p>{ polyglot.t('random_text') }</p>
              <p>
                <Button variant='primary'>{ polyglot.t('cancel_button') }</Button>-
                <Button variant='primary'>{ polyglot.t('submit_button') }</Button>
              </p>
              <SimpleModal
                label={polyglot.t('confirm_modal_button.label')}
                confirmButtonLabel={polyglot.t('confirm_modal_button.confirmation.confirm_button.label')}
                cancelButtonLabel={polyglot.t('confirm_modal_button.confirmation.cancel_button.label')}
                description={polyglot.t('confirm_modal_button.confirmation.content')}
              />
            </TextContent>
          </CardBody>
        </Card>
      </PageSection>
    </>
  )
}

interface ModalProsp {
  label: string
  confirmButtonLabel: string
  cancelButtonLabel: string
  description: string
}
const SimpleModal = (props: ModalProsp) => {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const handleModalToggle = (): void => setIsModalOpen(!isModalOpen)

  return (
    <React.Fragment>
        <Button variant="primary" onClick={handleModalToggle}>
          {props.label}
        </Button>
        <Modal
          title="Modal Header"
          isOpen={isModalOpen}
          onClose={handleModalToggle}
          actions={[
            <Button key="confirm" variant="primary" onClick={handleModalToggle}>
              {props.confirmButtonLabel}
            </Button>,
            <Button key="cancel" variant="link" onClick={handleModalToggle}>
              {props.cancelButtonLabel}
            </Button>
          ]}
          isFooterLeftAligned
        >
          {props.description}
        </Modal>
      </React.Fragment>
  )
}

export default Overview
