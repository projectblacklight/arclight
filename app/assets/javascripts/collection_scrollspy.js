Blacklight.onLoad(function () {
  'use strict';

  $('.al-sticky-sidebar').Stickyfill();
  $('body').scrollspy({ target: '.al-sidebar-navigation-context' });
});
