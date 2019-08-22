Blacklight.onLoad(function () {
  'use strict';

  var histogramContent = $('#al-date-range-histogram-content');
  var showSpan = $('#al-date-range-histogram-show');
  var hideSpan = $('#al-date-range-histogram-hide');
  histogramContent.on('show.bs.collapse', function () {
    showSpan.attr('hidden', 'hidden');
    hideSpan.removeAttr('hidden');
  });
  histogramContent.on('hide.bs.collapse', function () {
    hideSpan.attr('hidden', 'hidden');
    showSpan.removeAttr('hidden');
  });
});
