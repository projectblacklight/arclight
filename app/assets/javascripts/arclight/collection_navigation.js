(function (global) {
  var CollectionNavigation = {
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
          view: 'hierarchy',
          per_page: 9999999
        }
      }).done(function (response) {
        var resp = $.parseHTML(response);
        var $doc = $(resp);
        var showDocs = $doc.find('article.document');

        // Add a highlight class here for containing text. We need to parse the
        // area for text as it is potentially encoded.
        var parsedHighlightText = $('<textarea/>').html(data.arclight.highlight).val();
        if (parsedHighlightText) {
          $doc.find('article:contains(' + parsedHighlightText + ')').addClass('al-hierarchy-highlight');
        }

        $el.hide().html($doc.find('#documents')).fadeIn(500);
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
