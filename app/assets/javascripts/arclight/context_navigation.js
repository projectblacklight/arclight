class NavigationDocument {
  constructor(el) {
    this.el = $(el);
  }

  get id() {
    return this.el.find('[data-document-id]').data().documentId;
  }

  setAsHighlighted() {
    this.el.find('li.al-collection-context').addClass('al-hierarchy-highlight');
  }

  render() {
    return this.el.html();
  }
}

class ContextNavigation {
  constructor(el) {
    this.el = $(el);
    this.data = this.el.data();
    this.parentLi = this.el.parent();
  }

  static placeholder() {
    const placeholder = '<div class="al-hierarchy-placeholder">' +
                          '<h3 class="col-md-9"></h3>' +
                          '<p class="col-md-6"></p>' +
                          '<p class="col-md-12"></p>' +
                          '<p class="col-md-3"></p>' +
                        '</div>';
    return new Array(3).join(placeholder);
  }

  getData() {
    const that = this;
    // Add a placeholder so flashes of text are not as significant
    this.el.after(ContextNavigation.placeholder());
    $.ajax({
      url: this.data.arclight.path,
      data: {
        'f[component_level_isim][]': this.data.arclight.level,
        'f[has_online_content_ssim][]': this.data.arclight.access,
        'f[collection_sim][]': this.data.arclight.name,
        'f[parent_ssi][]': this.data.arclight.parent,
        search_field: this.data.arclight.search_field,
        view: 'collection_context'
      }
    }).done((response) => that.updateView(response));
  }

  updateView(response) {
    const that = this;
    var resp = $.parseHTML(response);
    var $doc = $(resp);
    var newDocs = $doc.find('#documents')
      .find('article')
      .toArray().map(el => new NavigationDocument(el));

    const originalDocumentIndex = newDocs
      .findIndex(doc => doc.id === that.data.arclight.originalDocument);
    that.parentLi.find('.al-hierarchy-placeholder').remove();

    // Case where this is the sibling tree of the current document
    if (originalDocumentIndex !== -1) {
      newDocs[originalDocumentIndex].setAsHighlighted();
      that.parentLi.before(newDocs.map(newDoc => newDoc.render()).join('')).fadeIn(500);
    } else {
    // Case where this is a parent list and needs to be filed correctly
      const parentIndex = that.data.arclight.originalParents.indexOf(that.data.arclight.parent);
      const currentId = `${that.data.arclight.originalParents[0]}${that.data.arclight.originalParents[parentIndex + 1]}`;
      const newDocIndex = newDocs.findIndex(doc => doc.id === currentId);

      // Update the docs before the item
      // TODO: Add a class or something that doesn't display these until the expando is clicked
      const beforeDocs = newDocs.slice(0, newDocIndex);
      that.parentLi.before(beforeDocs.map(newDoc => newDoc.render()).join('')).fadeIn(500);
      // Update the item
      const $itemDoc = $(newDocs.slice(newDocIndex, newDocIndex + 1).map(doc => doc.render()).join(''));
      // Update the id, add classes of the classes. Prepend the current children.
      that.parentLi.attr('id', $itemDoc.attr('id'));
      that.parentLi.addClass($itemDoc.attr('class'));
      that.parentLi.prepend($itemDoc.children()).fadeIn(500);
      // Update the docs after the item
      const afterDocs = newDocs.slice(newDocIndex + 1, newDocs.length);
      that.parentLi.after(afterDocs.map(newDoc => newDoc.render()).join('')).fadeIn(500);
    }
  }
}

Blacklight.onLoad(function () {
  $('.context-navigator').each(function (i, e) {
    const contextNavigation = new ContextNavigation(e);
    contextNavigation.getData();
  });
});
