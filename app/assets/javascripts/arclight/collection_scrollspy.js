/* eslint "no-new": "off" */
Blacklight.onLoad(function () {
  'use strict';

  if (typeof bootstrap !== 'undefined' && typeof bootstrap.ScrollSpy !== 'undefined' && bootstrap.ScrollSpy.VERSION >= '5') {
    new bootstrap.ScrollSpy(document.body, {
      target: '#collection-context-sidebar'
    });
  } else {
    $('body').scrollspy({ target: '#collection-context-sidebar' });
  }
});
