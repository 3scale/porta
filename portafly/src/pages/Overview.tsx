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

import { format, formatDistance, formatRelative, subDays } from 'date-fns'
import {
  enUS as DATEFNS_LOCALE_EN,
  ja as DATEFNS_LOCALE_JP
} from 'date-fns/locale'
import currency from 'currency.js'
import { I18nContext } from 'i18n/I18nProvider'
import { setupTranslate } from 'i18n/setupTranslate'
import { 
  OVERVIEW as STRINGS_ENG,
  COMMONS as COMMONS_ENG
} from 'i18n/locales/en'
import { 
  OVERVIEW as STRINGS_JAP,
  COMMONS as COMMONS_JAP
} from 'i18n/locales/jp'

const Overview: React.FunctionComponent = ({children}) => {
  const [strings, setStrings] = useState(STRINGS_ENG)
  const [commonStrings, setCommonStrings] = useState(COMMONS_ENG)
  const [locale, setLocale] = useState('en')
  const [dateFnsLocale, setDateFnsLocale] = useState(DATEFNS_LOCALE_EN)
  const [currencySymbol, setCurrencySymbol] = useState('$')
  const polyglot = useContext(I18nContext)
  const t = setupTranslate(polyglot, locale, { ...strings, ...commonStrings})

  const onClick = (event: React.SyntheticEvent<HTMLButtonElement>) => {
    const isEng = event.currentTarget.value === 'en'
    setStrings(isEng ? STRINGS_ENG : STRINGS_JAP)
    setCommonStrings(isEng ? COMMONS_ENG : COMMONS_JAP)
    setDateFnsLocale(isEng ? DATEFNS_LOCALE_EN : DATEFNS_LOCALE_JP)
    setCurrencySymbol(isEng ? '$' : '¥')
    setLocale(event.currentTarget.value)
  }

  useA11yRouteChange()
  useDocumentTitle(t('page_title'))
  return (
    <>
      <PageSection variant={'light'}>
        <TextContent>
          <p>
            <button value='en' onClick={onClick}>English</button>
            <button value='jp' onClick={onClick}>日本語</button>
          </p>
          <Title size={'3xl'}>{t('body_title')}</Title>
          <Text>
          <b>{ t('subtitle') }</b>
          </Text>
        </TextContent>
      </PageSection>
      <PageSection>
        <Card>
          <CardBody>
            <TextContent>
              <p>{ t('greetings') }</p>
              <p>
                { t('greetings_with_place', { name: 'Juan Doe', place: 'portafly'}) }
              </p>
              <p>{ t('dates') }:</p>
              <p><b>JS Date():</b></p>
              <p>{ t('date', { date: Date.now() }) }</p>
              <p>new Date('2015-03-25'): { t('date', { date: new Date('2015-03-25') }) }</p>
              <p><b>date-fns:</b></p>
              <p> 
                { t(format(new Date(), "eeee, dd MMM yyyy", {locale: dateFnsLocale }) )}
              </p>
              <p> 
                { t(formatRelative(subDays(new Date(), 3), new Date(), { locale: dateFnsLocale })) }
              </p>
              <p> 
                { t(formatDistance(new Date(2016, 7, 1), new Date(2015, 0, 1), { locale: dateFnsLocale })) }
              </p>
              <p><b>Currencies:</b></p>
              <p>
                { t(currency(1500, { symbol: currencySymbol, precision: 2 }).format(true)) }
              </p>
              <p><b>{ t('plurals') }:</b></p>
              <ul>
                <li>{ t('count_apple', { smart_count: 0 }) }</li>
                <li>{ t('count_apple', { smart_count: 1 }) }</li>
                <li>{ t('count_apple', { smart_count: 2 }) }</li>
              </ul>
              <p>{ t('random_text') }</p>
              <p>
                <Button variant='primary'>{ t('cancel_button') }</Button>-
                <Button variant='primary'>{ t('submit_button') }</Button>
              </p>
              <SimpleModal
                label={t('confirm_modal_button.label')}
                heading={t('confirm_modal_button.confirmation.heading')}
                confirmButtonLabel={t('confirm_modal_button.confirmation.confirm_button.label')}
                cancelButtonLabel={t('confirm_modal_button.confirmation.cancel_button.label')}
                description={t('confirm_modal_button.confirmation.content')}
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
  heading: string
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
          title={props.heading}
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
