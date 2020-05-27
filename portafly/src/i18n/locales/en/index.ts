// @ts-nocheck // TODO: make tslint to recognize yml files

// Shared files
import shared from 'i18n/locales/en/shared.yml'
import overview from 'i18n/locales/en/overview.yml'
import login from 'i18n/locales/en/login.yml'
// Applications
import applicationsListing from 'i18n/locales/en/applications/listing.yml'
import applicationsPlans from 'i18n/locales/en/applications/applications_plans.yml'
// Accounts
import accountPersonal from 'i18n/locales/en/account_settings/personal/personal.yml'
import accountPersonalTokens from 'i18n/locales/en/account_settings/personal/tokens.yml'
import accountPersonalDetails from 'i18n/locales/en/account_settings/personal/personal_details.yml'
import accountPersonalNotificationPreferences from 'i18n/locales/en/account_settings/personal/notification_preferences.yml'
import accountUsersListing from 'i18n/locales/en/account_settings/users/listing-invitations.yml'
// Analytics
import analyticsUsage from 'i18n/locales/en/analytics/usage.yml'
// Integration
import integrationConfiguration from 'i18n/locales/en/integration/configuration.yml'

const applications = {
  listing: applicationsListing,
  plans: applicationsPlans
}

const accounts = {
  personal: {
    ...accountPersonal,
    tokens: accountPersonalTokens,
    details: accountPersonalDetails,
    notifications: accountPersonalNotificationPreferences
  },
  users: accountUsersListing
}

const analytics = {
  analyticsUsage
}

const integration = {
  integrationConfiguration
}


export {
  shared,
  overview,
  analytics,
  applications,
  accounts,
  integration,
  login
}
