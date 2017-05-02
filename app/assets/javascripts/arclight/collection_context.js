Blacklight.onLoad(function () {
  'use strict';

  $('[data-arclight-collection-context="true"]').each(function (i, element) {
    var $el = $(element);
    var data = $el.data();
    $.ajax({
      url: data.arclightCollectionContextUrl
    }).done(function (response) {
      var resp = $.parseHTML(response);
      var $doc = $(resp);
      $el.hide().html($doc.find('.al-show-header-section')).fadeIn(500);
    });
  });
});
