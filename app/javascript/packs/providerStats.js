import { statsUsage } from 'Stats/provider/stats_usage'
import { statsDaysOfWeek } from 'Stats/provider/stats_days_of_week'
import { statsHoursOfDay } from 'Stats/provider/stats_hours_of_day'
import { statsTopApps } from 'Stats/provider/stats_top_apps'
import { statsApplication } from 'Stats/provider/stats_application'
import { statsResponseCodes } from 'Stats/provider/stats_response_codes'
import $ from 'jquery'

document.addEventListener('DOMContentLoaded', () => {
  window.$ = $
  window.statsUsage = statsUsage
  window.statsDaysOfWeek = statsDaysOfWeek
  window.statsHoursOfDay = statsHoursOfDay
  window.statsTopApps = statsTopApps
  window.statsApplication = statsApplication
  window.statsResponseCodes = statsResponseCodes
})
