  const CollectionNavigation = {
    init: function (el, page = 1) {
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

      const params = new URLSearchParams({
        'f[component_level_isim][]': data.arclight.level,
        'f[collection_sim][]': data.arclight.name,
        'f[parent_ssim][]': data.arclight.parent,
        page: page,
        search_field: data.arclight.search_field,
        view: data.arclight.view || 'hierarchy'
      });
      if (data.arclight.access) {
        params.append('f[has_online_content_ssim][]', data.arclight.access);
      }

      fetch(data.arclight.path + '?' + params)
      .then((response) => response.text())
      .then((body) => {
        const parser = new DOMParser()
        const resp = parser.parseFromString(body, 'text/html')
        var $doc = $(resp);
        var showDocs = $doc.find('article.document'); // The list of search results
        var newDocs = $doc.find('#documents'); // The container that holds the search results
        var sortPerPage = $doc.find('#sortAndPerPage'); // The row on the search page that has prev/next, per-page and relevance controls

        // Hide these until we re-enable in the future
        sortPerPage.find('.result-type-group').hide(); // Arclight's "Group by collection / All results"
        sortPerPage.find('.search-widgets').hide(); // Sort by and per-page widgets.

        sortPerPage.find('a').on('click', function (e) {
          // Make the previous and next links work via javascript and not as regular links
          var pages = [];
          var $target = $(e.target);
          e.preventDefault();
          pages = /page=(\d+)&/.exec($target.attr('href'));
          if (pages) {
            CollectionNavigation.init($el, pages[1]);
          } else {
            // Case where the "first" page
            CollectionNavigation.init($el);
          }
        });

        // Remove the placeholder and display the loaded docs.
        $el.hide().html('').append(sortPerPage).append(newDocs)
          .fadeIn(500);
        if (showDocs.length > 0) {
          $el.trigger('navigation.contains.elements');
        }
      });
    }
  };

  Blacklight.onLoad(function () {
    'use strict';

    $('.al-contents').each(function (i, element) {
      CollectionNavigation.init(element); // eslint-disable-line no-undef
    });

    $('.al-contents').on('navigation.contains.elements', function (e) {
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
