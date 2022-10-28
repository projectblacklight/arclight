import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content']

  connect() {
    // target elements
    const contentInner = Array.from(this.contentTarget.children)

    // calculate total scrollable inner height vs. observed outer height
    const outerHeight = this.contentTarget.clientHeight
    const innerHeight = contentInner.map(e => e.scrollHeight).reduce((a, b) => a + b, 0)

    // truncation occurred if total inner height exceeds outer (observed) height.
    // if no longer truncated, reset the expanded state (e.g. on window resize).
    if (innerHeight > outerHeight) {
      this.element.classList.add('truncated')
    } else {
      this.element.classList.remove('truncated')
      this.contentTarget.classList.remove('expanded')
    }
  }

  trigger() {
    this.element.classList.toggle('expanded')
  }
}
