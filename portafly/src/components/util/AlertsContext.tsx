import React, { useContext } from 'react'
import {
  AlertGroup,
  AlertActionCloseButton,
  Alert,
  AlertVariant
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'

interface IAlert {
  id: string
  variant: keyof typeof AlertVariant
  title: string
}

type IAlertsContext = { addAlert: (alert: IAlert) => void }
const AlertsContext = React.createContext<IAlertsContext>({ addAlert: () => {} })

const TIMEOUT = 8000

const AlertsProvider: React.FunctionComponent = ({ children }) => {
  const { t } = useTranslation('shared')

  type AlertsState = Array<IAlert & { timeout: NodeJS.Timeout }>
  const [alerts, setAlerts] = React.useState<AlertsState>([])

  const removeAlert = (id: string) => (
    setAlerts((prevAlerts) => prevAlerts.filter((a) => a.id !== id))
  )

  const addAlert = (alert: IAlert) => {
    const timeout = setTimeout(() => removeAlert(alert.id), TIMEOUT)
    setAlerts((prevAlerts) => [...prevAlerts, { ...alert, timeout }])
  }

  const CloseButton = ({ id, timeout }: { id: string, timeout: NodeJS.Timeout }) => (
    <AlertActionCloseButton
      title={t('alerts.close_button')}
      onClose={() => {
        removeAlert(id)
        clearTimeout(timeout)
      }}
    />
  )

  return (
    <AlertsContext.Provider value={{ addAlert }}>
      <AlertGroup isToast>
        {alerts.map(({
          id, variant, title, timeout
        }) => (
          <Alert
            key={id}
            isLiveRegion
            variant={variant}
            title={title}
            actionClose={<CloseButton id={id} timeout={timeout} />}
          />
        ))}
      </AlertGroup>
      {children}
    </AlertsContext.Provider>
  )
}

const useAlertsContext = () => useContext(AlertsContext)

export { AlertsProvider, useAlertsContext }
