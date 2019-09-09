Blacklight.onLoad(() => {
  'use strict';

  $('[data-arclight-collection-context="true"]').each(function (i, element) {
    var $el = $(element);
    var data = $el.data();
    $.ajax({
      url: data.arclightCollectionContextUrl
    }).done(function (response) {
      var resp = $.parseHTML(response);
      var $doc = $(resp);
      var link = $('<a></a>').attr('href', data.arclightCollectionContextUrl);
      var addedSection = $doc.find('.al-show-header-section');
      addedSection.find('h1').wrapInner(link);
      $el.hide().html(addedSection).fadeIn(500);
    });
  });
});
