(function (global) {
  var CollectionNavigation = {
    init: function (el) {
      var $el = $(el);
      var data = $el.data();

      $.ajax({
        url: data.arclight.path,
        data: {
          'f[component_level_isim][]': data.arclight.level,
          'f[collection_sim][]': data.arclight.name,
          view: 'hierarchy',
          per_page: 9999999
        }
      }).done(function (response) {
        var resp = $.parseHTML(response);
        var $doc = $(resp);
        var showDocs = $doc.find('article.document');
        $el.html($doc.find('#documents'));

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

  $('.al-contents').on('navigation.contains.elements', function () {
    var toEnable = $('[data-hierarchy-enable-me]');
    toEnable.removeClass('disabled');
    toEnable.text('Contents');
  });
});
