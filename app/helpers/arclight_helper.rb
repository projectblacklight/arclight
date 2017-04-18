# frozen_string_literal: true

##
# Generic Helpers used in Arclight
module ArclightHelper
  ##
  # @param [SolrDocument]
  def parents_to_links(document)
    safe_join(Arclight::Parents.from_solr_document(document).as_parents.map do |parent|
      link_to parent.label, solr_document_path(parent.global_id)
    end, t('arclight.breadcrumb_separator'))
  end
end
