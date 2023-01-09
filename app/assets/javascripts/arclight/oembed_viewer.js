class OembedLoader {
  constructor(el) {
    this.el = el
  }

  load() {
    const loadedAttr = this.el.getAttribute('loaded')
    const { arclightOembed, arclightOembedUrl, ...extraOembedParams } = this.el.dataset
    const extraParams = OembedLoader.normalizeParams(extraOembedParams)

    if (loadedAttr && loadedAttr === 'loaded') {
      return
    }

    fetch(arclightOembedUrl)
      .then((response) => response.text())
      .then((body) => {
        const oEmbedEndPoint = OembedLoader.findOEmbedEndPoint(body, extraParams)
        if (!oEmbedEndPoint || oEmbedEndPoint.length === 0) {
          console.warn(`No oEmbed endpoint found in <head> at ${arclightOembedUrl}`)
          return
        }
        this.loadEndPoint(oEmbedEndPoint)
      })
  }

  // Convert data-arclight-oembed-* attributes to URL parameters for the viewer
  static normalizeParams(attributes) {
    return Object.keys(attributes).reduce((acc, attribute) => {
      // Reverse data attribute name conversion. See:
      // https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dataset#name_conversion
      const parameterName = attribute.replace('arclightOembed', '')
        .replace(/([a-z])([A-Z])/g, '$1-$2')
        .toLowerCase()

      acc[parameterName] = attributes[attribute]
      return acc
    }, {})
  }

  static findOEmbedEndPoint(body, extraParams = {}) {
    // Parse out link elements so image assets are not loaded
    const template = document.createElement('template')
    template.innerHTML = body.match(/<link .*>/g).join('')

    // Look for a link element containing the oEmbed endpoint; bail out if none
    const endpoint = template.content.querySelector('link[rel="alternate"][type="application/json+oembed"]')
      ?.getAttribute('href')
    if (!endpoint) return ''

    // Serialize any extra params and append them to the endpoint
    const qs = new URLSearchParams(extraParams).toString()
    return `${endpoint}&${qs}`
  }

  loadEndPoint(oEmbedEndPoint) {
    fetch(oEmbedEndPoint)
      .then((response) => response.json())
      .then((json) => {
        this.el.innerHTML = json.html
        this.el.setAttribute('loaded', 'loaded')
      })
  }
}

Blacklight.onLoad(function () {
  document.querySelectorAll('[data-arclight-oembed="true"]').forEach((element) => {
    const loader = new OembedLoader(element)
    loader.load()
  })
})
