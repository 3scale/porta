import {Onboarding, Bubble} from 'Onboarding/Bubble'

describe('ApiBubble', () => {
  beforeEach(() => {
    fixture.set('<a data-bubble="integration" /></a>')
  })

  let bubble = Bubble.get('api')

  it('has a name', () => {
    expect(bubble.name).toBe('api')
  })

  it('has description', () => {
    expect(bubble.description).toContain('API')
  })

  it('has html', () => {
    expect(bubble.html()).toContainElement('span.Onboarding-bubble-description')
  })

  describe('DOM', () => {
    it('renders', () => {
      bubble.render()

      expect(fixture.el).toContainHtml(bubble.html())
    })
  })
})

describe('Onboarding', () => {
  it('has bubbles by default', () => {
    let onboarding = new Onboarding()
    expect(onboarding.bubbles).toEqual([])
  })

  it('has bubbles passed by initializer', () => {
    let onboarding = new Onboarding(['api'])
    let api = onboarding.bubbles[0]
    expect(api.name).toEqual('api')
  })
})
