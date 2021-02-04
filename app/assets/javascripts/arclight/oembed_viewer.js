// Load a single oEmbed viewer bound to an element
function loadViewer(element) {
  var $el = $(element);
  var loadedAttr = $el.attr('loaded');
  var data = $el.data();
  var resourceUrl = data.arclightOembedUrl;
  if (loadedAttr && loadedAttr === 'loaded') {
    return;
  }

  $.ajax({
    url: resourceUrl,
    dataType: 'html'
  }).done(function (response) {
    var links = $('<div>' + response.match(/<link .*>/g).join('') + '</div>'); // Parse out link elements so image assets are not loaded
    var oEmbedEndPoint = links.find('link[rel="alternate"][type="application/json+oembed"]').prop('href');

    if (!oEmbedEndPoint || oEmbedEndPoint.length === 0) {
      return;
    }

    $.ajax({
      url: oEmbedEndPoint
    }).done(function (oEmbedResponse) {
      if (oEmbedResponse.html) {
        $el.hide()
          .html(oEmbedResponse.html)
          .fadeIn(500);
        $el.attr('loaded', 'loaded');
      }
    });
  });
}

// Find and load all oEmbed viewers in the provided context element
function loadViewers(context) {
  var oEmbedViewerSelector = '[data-arclight-oembed="true"]';
  var $viewerElements = context.find(oEmbedViewerSelector);

  if ($viewerElements.length === 0) {
    return;
  }

  $viewerElements.each(function (i, element) {
    loadViewer(element);
  });
}

Blacklight.onLoad(function () {
  'use strict';

  var onlineContentTabSelector = '[data-arclight-online-content-tab="true"]';

  // Attempt to load viewers directly in the page
  loadViewers($('body'));

  // Load viewers hidden behind tabs when the tab content is displayed
  $(onlineContentTabSelector).on('shown.bs.tab', function () {
    loadViewers($(this));
  });
});
