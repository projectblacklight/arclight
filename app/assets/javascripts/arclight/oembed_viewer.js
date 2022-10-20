class OembedLoader {
  constructor(el) {
    this.el = el
  }

  load() {
    const loadedAttr = this.el.getAttribute('loaded')
    var data = this.el.dataset
    var resourceUrl = data.arclightOembedUrl
    if (loadedAttr && loadedAttr === 'loaded') {
      return
    }

    fetch(resourceUrl)
      .then((response) => response.text())
      .then((body) => {
        const oEmbedEndPoint = this.findOEmbedEndPoint(body)
        if (!oEmbedEndPoint || oEmbedEndPoint.length === 0) {
          return
        }
        this.loadEndPoint(oEmbedEndPoint)
      })
  }

  static findOEmbedEndPoint(body) {
    const template = document.createElement('template')
    template.innerHTML = body.match(/<link .*>/g).join('') // Parse out link elements so image assets are not loaded
    return template.querySelector('link[rel="alternate"][type="application/json+oembed"]').getAttribute('href')
  }

  loadEndPoint(oEmbedEndPoint) {
    fetch(oEmbedEndPoint)
      .then((response) => response.text())
      .then((body) => {
        this.el.innerHTML = body
        this.el.setAttribute('loaded', 'loaded')
      })
  }
}

Blacklight.onLoad(function () {
  'use strict'

  document.querySelectorAll('[data-arclight-oembed="true"]').forEach((element) => {
    const loader = new OembedLoader(element)
    loader.load()
  })
})
