Blacklight.onLoad(function () {
  'use strict';

  var histogram_content = $('#al-date-range-histogram-content')
  var show_span = $('#al-date-range-histogram-show')
  var hide_span = $('#al-date-range-histogram-hide')
  histogram_content.on('show.bs.collapse', function() {
    show_span.attr('hidden', 'hidden')
    hide_span.removeAttr('hidden')
  })
  histogram_content.on('hide.bs.collapse', function() {
    hide_span.attr('hidden', 'hidden')
    show_span.removeAttr('hidden')
  })
});
