// Developer Portal stats. Loaded by lib/developer_portal/app/views/developer_portal/stats/_chart.html.liquid.
//
// This file requires jQuery, which is loaded in the tenant's main layout (e.g. cdn_asset or essential_assets).
//
// Stats and jQueryUI datepicker support jQuery >= 1.7.

import { statsApplication } from 'Stats/buyer/stats_application'

window.Stats = { statsApplication }
