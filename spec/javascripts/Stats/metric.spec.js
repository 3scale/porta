import {StatsMetric} from '../../../app/javascript/src/Stats/lib/metric'

describe('StatsMetric', () => {
  it('should create the right metric', () => {
    let methodAttributes = {
      created_at: '2012-03-13T10:38:59-07:00',
      description: '',
      friendly_name: 'transactions/create_single',
      id: 42,
      parent_id: 6,
      service_id: 6,
      system_name: 'transactions/create_single',
      unit: 'hit',
      updated_at: '2012-03-13T10:38:59-07:00'
    }
    let method = new StatsMetric(methodAttributes)

    expect(method).toEqual(jasmine.any(StatsMetric))
    expect(method.isMethod).toEqual(true)
    expect(method.id).toEqual(42)
  })
})
