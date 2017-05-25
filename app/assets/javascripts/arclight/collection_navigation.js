(function (global) {
  var CollectionNavigation;
  /**
   * Converts documents that should be used in a hierarchy, to highlighted
   * localized siblings.
   */
  function convertDocsForContext(parsedHighlightText, $doc) {
    var newDocs;
    var $currentDoc;
    var $previousDocs;
    var $nextDocs;
    $currentDoc = $doc.find('article:contains(' + parsedHighlightText + ')');
    $currentDoc.addClass('al-hierarchy-highlight');

    $previousDocs = $currentDoc.prevUntil().slice(0, 2);
    $nextDocs = $currentDoc.nextUntil().slice(0, 2);

    // Case where there are siblings on both sides
    if ($previousDocs.length > 0 && $nextDocs.length > 0) {
      newDocs = $('<div>');
      newDocs.append($previousDocs.first());
      newDocs.append($currentDoc);
      newDocs.append($nextDocs.first());
    } else if ($previousDocs.length > 0) {
      // Case where there are only previous siblings
      newDocs = $('<div>');
      newDocs.append($previousDocs);
      newDocs.append($currentDoc);
    } else {
      // Case where there are only next siblings
      newDocs = $('<div>');
      newDocs.append($currentDoc);
      newDocs.append($nextDocs);
    }
    // Cleanup to remove collapsible children stuff
    newDocs.find('.al-toggle-view-more').remove();
    newDocs.find('.collapse').remove();
    newDocs.find('hr').remove();
    return newDocs;
  }

  CollectionNavigation = {
    init: function (el) {
      var $el = $(el);
      var data = $el.data();
      // Add a placeholder so flashes of text are not as significant
      var placeholder = '<div class="al-hierarchy-placeholder">' +
                          '<h3 class="col-md-9"></h3>' +
                          '<p class="col-md-6"></p>' +
                          '<p class="col-md-12"></p>' +
                          '<p class="col-md-3"></p>' +
                        '</div>';
      placeholder = new Array(3).join(placeholder);
      $el.html(placeholder);
      $.ajax({
        url: data.arclight.path,
        data: {
          'f[component_level_isim][]': data.arclight.level,
          'f[collection_sim][]': data.arclight.name,
          'f[parent_ssi][]': data.arclight.parent,
          view: 'hierarchy'
        }
      }).done(function (response) {
        var resp = $.parseHTML(response);
        var $doc = $(resp);
        var showDocs = $doc.find('article.document');
        var newDocs = $doc.find('#documents');

        // Add a highlight class here for containing text. We need to parse the
        // area for text as it is potentially encoded. This is also the case
        // that we only want to include localized siblings
        var parsedHighlightText = $('<textarea/>').html(data.arclight.highlight).val();
        if (parsedHighlightText) {
          newDocs = convertDocsForContext(parsedHighlightText, $doc);
        }

        $el.hide().html(newDocs).fadeIn(500);
        if (showDocs.length > 0) {
          $el.trigger('navigation.contains.elements');
        }
      });
    }
  };

  global.CollectionNavigation = CollectionNavigation;
}(this));

Blacklight.onLoad(function () {
  'use strict';

  $('.al-contents').each(function (i, element) {
    CollectionNavigation.init(element); // eslint-disable-line no-undef
  });

  $('.al-contents').on('navigation.contains.elements', function (e) {
    var toEnable = $('[data-hierarchy-enable-me]');
    toEnable.removeClass('disabled');
    toEnable.text('Contents');

    $(e.target).find('.collapse').on('show.bs.collapse', function (ee) {
      var $newTarget = $(ee.target);
      $newTarget.find('.al-contents').each(function (i, element) {
        CollectionNavigation.init(element); // eslint-disable-line no-undef
        // Turn off additional ajax requests on show
        $newTarget.off('show.bs.collapse');
      });
    });
  });
});
