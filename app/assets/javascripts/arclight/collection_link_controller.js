import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['link']

  connect() {
    this.highlight({ newURL: document.documentURI })
  }

  highlight(event) {
    this.linkTarget.classList.toggle('active', event.newURL.endsWith(this.linkTarget.href))
  }
}
