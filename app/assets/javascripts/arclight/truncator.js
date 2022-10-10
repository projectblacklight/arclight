Blacklight.onLoad(function () {
  'use strict'

  // Any element on page load
  $('[data-arclight-truncate="true"]').each(function (i, el) {
    $(el).responsiveTruncate({
      more: el.dataset.truncateMore,
      less: el.dataset.truncateLess
    })
  })

  // When elements get loaded from hierarchy
  $('.al-contents, .context-navigator').on('navigation.contains.elements', function (e) {
    const tabs = document.querySelectorAll('button[data-bs-toggle="tab"]')
    tabs.forEach(tab => {
      tab.addEventListener('shown.bs.tab', () => {
        $('[data-arclight-truncate="true"]').each(function (_, el) {
          $(el).responsiveTruncate({
            more: el.dataset.truncateMore,
            less: el.dataset.truncateLess
          })
        })
      })
    })
    $(e.target).find('[data-arclight-truncate="true"]').each(function (_, el) {
      $(el).responsiveTruncate({
        more: el.dataset.truncateMore,
        less: el.dataset.truncateLess
      })
    })
  })
})
