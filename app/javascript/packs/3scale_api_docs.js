import { ActiveDocsSpecWrapper as ActiveDocsSpec } from 'ActiveDocs/components/ActiveDocsSpec'

document.addEventListener('DOMContentLoaded', () => {
  ['accounts', 'analytics', 'finance'].forEach(name => {
    ActiveDocsSpec({
      url: `/p/admin/api_docs/specs/${name}`,
      docExpansion: 'none'
    }, `swagger-ui-${name}`)
  })
})
