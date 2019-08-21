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
    var headers = $doc.find('article div[data-document-id="' + id + '"]');
    if (headers.length === 0) {
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

  /** Class for generating placeholder markup for the AJAX requests */
  function Placeholder() {

    /**
     * Generate the placeholder markup
     * @return {string} the HTML for the placeholder
     */
    this.render = function() {
      var html = '<div class="al-hierarchy-placeholder">' +
                          '<h3 class="col-md-9"></h3>' +
                          '<p class="col-md-6"></p>' +
                          '<p class="col-md-12"></p>' +
                          '<p class="col-md-3"></p>' +
                        '</div>';
      var output = new Array(3).join(html);
      return output;
    }
  }

  /**
    * Class for handling responses from the catalog endpoint
    * @param {ContentRequest} request
    */
  function ContentResponse(request) {
    this.request = request;

    /**
     * Resolve the response and invoke a callback for the payload
     */
    this.resolve = function(callback) {
      this.request.send(callback);
    }
  }

  /** Class for transmitting and receiving requests from the catalog endpoint */
  function ContentRequest($el, data) {
    this.$el = $el;
    this.data = data;

    /**
     * Generate the response
     * @return {ContentResponse} the response object
     */
    this.getResponse = function() {
      return new ContentResponse(this);
    }

    /**
     * @param {function} callback a function which takes the server payload as an argument
     */
    this.send = function(callback) {
      var placeholder = new Placeholder();
      this.$el.html(placeholder.render());
      var requestData = {
        'f[component_level_isim][]': this.data.arclight.level,
        'f[has_online_content_ssim][]': this.data.arclight.access,
        'f[collection_sim][]': this.data.arclight.name,
        'f[parent_ssi][]': this.data.arclight.parent,
        search_field: this.data.arclight.search_field,
        view: this.data.arclight.view || 'hierarchy',
        limit: this.data.arclight.limit || 10
      };

      var that = this;
      $.ajax({
        url: this.data.arclight.path,
        data: requestData
      }).done(function(response) {
        this.resp = $.parseHTML(response);
        this.$doc = $(this.resp);
        var showDocs = this.$doc.find('article.document');
        var newDocs = this.$doc.find('#documents');
        var paginationElements = this.$doc.find('.pagination');

        // Add a highlight class for the article matching the highlight id
        if (that.data.arclight.highlightId) {
          // This should be removed from the global scope
          newDocs = convertDocsForContext(that.data.arclight.highlightId, this.$doc);
        }

        // Ensure that the pagination elements are added to the AJAX-loaded
        // content
        if (paginationElements.length > 0) {
          newDocs.append(paginationElements);

          // Override the handlers to refresh the content
          var paginationLinks = paginationElements.find('a')
          paginationLinks.on('click', function(e) {
            e.preventDefault();

            var $linkElement = $(e.target);
            var href = $linkElement.attr('href');
            that.data.arclight.path = href;
            that.send();
          });
        }

        // Invoke the callback
        if (callback) {
          callback.call(response, this);
        }

        that.$el.hide().html(newDocs).fadeIn(500);
        if (showDocs.length > 0) {
          that.$el.trigger('navigation.contains.elements');
        }
        Blacklight.doBookmarkToggleBehavior();
      });
    }
  }

  CollectionNavigation = {
    init: function (el) {
      var $el = $(el);
      var data = $el.data();
      var request = new ContentRequest($el, data);
      var response = request.getResponse();
      response.resolve();
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
