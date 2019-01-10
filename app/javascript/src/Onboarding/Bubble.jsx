export class Bubble {
  static get (name) {
    switch (name) {
      case 'api' :
        return new ApiBubble()
      case 'metric' :
        return new MetricBubble()
      case 'mapping' :
        return new MappingBubble()
      case 'limit' :
        return new LimitBubble()
      case 'deployment' :
        return new DeploymentBubble()
    }
  }

  element () {
    let original = document.querySelector(this.selector)

    if (!original) {
      throw new Error(`Could not find element: ${this.selector}`)
    }

    return original
  }

  html () {
    let element = this.element().cloneNode(true)

    element.setAttribute('id', `onboarding-bubble-${this.name}`)
    element.className = 'Onboarding-bubble'
    element.innerHTML =
      `<span class="Onboarding-bubble-description">${this.description}</span>`
    return element
  }

  render () {
    let element = this.element()
    let html = this.html()
    let bubble = element.parentNode.insertBefore(html, element.nextSibling)

    return bubble
  }
}

export class Onboarding {
  constructor (bubbles = []) {
    this.bubbles = bubbles.map(b => Bubble.get(b))
  }

  render () {
    this.bubbles.forEach(b => b.render())
  }
}

class ApiBubble extends Bubble {
  constructor () {
    super()
    this.name = 'api'
    this.selector = 'a[data-bubble=integration]'
    this.description = 'Add an API to 3scale though the wizard.'
  }

  html () {
    let element = super.html()
    element.setAttribute('href', '/p/admin/onboarding/wizard/api/new')

    let analytics = window.analytics
    if (analytics) {
      analytics.trackLink(element, 'Wizard Step', {
        step: 'resumed'
      })
    }

    return element
  }
}

class MetricBubble extends Bubble {
  constructor () {
    super()
    this.name = 'metric'
    this.selector = 'a[data-bubble=metric]'
    this.description = 'Define the methods of this API.'
  }
}

class MappingBubble extends Bubble {
  constructor () {
    super()
    this.name = 'mapping'
    this.selector = 'a[data-bubble=mapping]'
    this.description = 'Add a mapping rule for this metric.'
  }
}

class LimitBubble extends Bubble {
  constructor () {
    super()
    this.name = 'limit'
    this.selector = 'a[data-bubble=limit]'
    this.description = 'Package your API in different plans with usage limits.'
  }
}

class DeploymentBubble extends Bubble {
  constructor () {
    super()
    this.name = 'deployment'
    this.selector = 'a[data-bubble=integration]'
    this.description = 'Secure your API and deploy to production.'
  }
}

export function show (bubbles) {
  let onboarding = new Onboarding(bubbles)

  onboarding.render()
}
