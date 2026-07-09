// Developer Portal stats. Loaded by lib/developer_portal/app/views/developer_portal/stats/_chart.html.liquid.
// jQuery comes from the tenant's template (e.g. cdn_asset or essential_assets).
// jQuery UI datepicker is bundled by webpack via Stats/lib/menu.js and attaches to the tenant's jQuery.

import { statsApplication } from 'Stats/buyer/stats_application'

window.Stats = { statsApplication }
