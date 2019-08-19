(function (global) {
  var CollectionNavigation;
  /**
   * Converts documents that should be used in a hierarchy, to highlighted
   * localized siblings.
   */
  function convertDocsForContext(id, $doc) {
    var newDocs;
    var $currentDoc;
    var $previousDocs;
    var $nextDocs;
    var headers = $doc.find('article header[data-document-id="' + id + '"]')
    if (headers.length == 0) {
      $.error('Document is missing id=' + id);
    }
    $currentDoc = $(headers[0].parentNode); // need article element
    $currentDoc.addClass('al-hierarchy-highlight');

    // Unlink the current component - just show the title
    $currentDoc.find('a').contents().unwrap();

    // We want to show 0-1 or 0-2 siblings depending on where highlighted component is
    $previousDocs = $currentDoc.prevUntil().slice(0, 2);
    $nextDocs = $currentDoc.nextUntil().slice(0, 2);

    if ($previousDocs.length > 0 && $nextDocs.length > 0) {
      // Case where there are siblings on both sides, show 1 each
      newDocs = $('<div>');
      newDocs.append($previousDocs.first());
      newDocs.append($currentDoc);
      newDocs.append($nextDocs.first());
    } else if ($previousDocs.length > 0) {
      // Case where there are only previous siblings, show 2 of them
      newDocs = $('<div>');
      newDocs.append($previousDocs.get().reverse()); // previous is not in the order we need
      newDocs.append($currentDoc);
    } else {
      // Case where there are only next siblings, show 2 of them
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
          'f[has_online_content_ssim][]': data.arclight.access,
          'f[collection_sim][]': data.arclight.name,
          'f[parent_ssi][]': data.arclight.parent,
          search_field: data.arclight.search_field,
          view: data.arclight.view || 'hierarchy'
        }
      }).done(function (response) {
        var resp = $.parseHTML(response);
        var $doc = $(resp);
        var showDocs = $doc.find('article.document');
        var newDocs = $doc.find('#documents');

        // Add a highlight class for the article matching the highlight id
        if (data.arclight.highlightId) {
          newDocs = convertDocsForContext(data.arclight.highlightId, $doc);
        }

        $el.hide().html(newDocs).fadeIn(500);
        if (showDocs.length > 0) {
          $el.trigger('navigation.contains.elements');
        }
        Blacklight.doBookmarkToggleBehavior();
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
