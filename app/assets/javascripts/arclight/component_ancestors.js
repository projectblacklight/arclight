(function (global) {
  var ComponentAncestors = {
    init: function (el) {
      var $el = $(el);
      var data = $el.data();
      var ancestors = $('<div>');
      var collectionId = data.arclightAncestors.shift();
      var allDone = $.Deferred();

      data.arclightAncestors.forEach(function (id, i) {
        var requestId = collectionId + id;
        var currentDiv = $('<div class="documents-hierarchy extra-indent al-hierarchy-level-' + (i) + '">');
        ancestors.append(currentDiv);

        $.ajax({
          url: data.arclightPath,
          data: {
            q: 'id:' + requestId,
            search_field: 'all_fields',
            view: 'hierarchy'
          }
        }).done(function (response) {
          var resp = $.parseHTML(response);
          var $doc = $(resp);
          var thisAncestor = $doc.find('article.document-position-0');

          // Remove collapsible stuff
          thisAncestor.find('.al-toggle-view-more').remove();
          thisAncestor.find('.collapse').remove();
          thisAncestor.find('hr').remove();

          currentDiv.append(thisAncestor);
          if (i + 1 === data.arclightAncestors.length) {
            allDone.resolve();
          }
        });
      });

      // Wait for all requests to finish
      allDone.done(function () {
        $el.html(ancestors);
      });
    }
  };

  global.ComponentAncestors = ComponentAncestors;
}(this));


Blacklight.onLoad(function () {
  'use strict';

  $('[data-arclight-ancestors]').each(function (i, e) {
    ComponentAncestors.init(e); // eslint-disable-line no-undef
  });
});
