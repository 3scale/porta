// @ts-nocheck // TODO: make tslint to recognize yml files

// Shared files
import shared from 'i18n/locales/en/shared.yml'
import overview from 'i18n/locales/en/overview.yml'
import login from 'i18n/locales/en/login.yml'
// Audience
import accountsIndex from 'i18n/locales/en/audience/accounts/listing.yml'
// Applications
import applicationsIndex from 'i18n/locales/en/applications/listing.yml'
import applicationsPlans from 'i18n/locales/en/applications/applications_plans.yml'
// Accounts
import accountSettingsPersonal from 'i18n/locales/en/account_settings/personal/personal.yml'
import accountSettingsPersonalTokens from 'i18n/locales/en/account_settings/personal/tokens.yml'
import accountSettingsPersonalDetails from 'i18n/locales/en/account_settings/personal/personal_details.yml'
import accountSettingsPersonalNotificationPreferences from 'i18n/locales/en/account_settings/personal/notification_preferences.yml'
import accountSettingsUsersListing from 'i18n/locales/en/account_settings/users/listing-invitations.yml'
// Analytics
import analyticsUsage from 'i18n/locales/en/analytics/usage.yml'
// Integration
import integrationConfiguration from 'i18n/locales/en/integration/configuration.yml'

const accounts = {
  personal: {
    ...accountSettingsPersonal,
    tokens: accountSettingsPersonalTokens,
    details: accountSettingsPersonalDetails,
    notifications: accountSettingsPersonalNotificationPreferences
  },
  users: accountSettingsUsersListing
}

const analytics = {
  analyticsUsage
}

const integration = {
  integrationConfiguration
}


export {
  applicationsPlans,
  applicationsIndex,
  accountsIndex,
  shared,
  overview,
  analytics,
  accounts,
  integration,
  login
}
