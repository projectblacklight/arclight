Blacklight.onLoad(function () {
  'use strict';

  // Any element on page load
  $('[data-arclight-truncate="true"]').each(function (i, el) {
    $(el).responsiveTruncate({
      more: el.dataset.truncateMore,
      less: el.dataset.truncateLess
    });
  });

  // When elements get loaded from hierarchy
  $('.al-contents, .context-navigator').on('navigation.contains.elements', function (e) {
    $('[data-toggle="tab"]').on('shown.bs.tab', function () {
      $('[data-arclight-truncate="true"]').each(function (_, el) {
        $(el).responsiveTruncate({
          more: el.dataset.truncateMore,
          less: el.dataset.truncateLess
        });
      });
    });
    $(e.target).find('[data-arclight-truncate="true"]').each(function (_, el) {
      $(el).responsiveTruncate({
        more: el.dataset.truncateMore,
        less: el.dataset.truncateLess
      });
    });
  });
});
