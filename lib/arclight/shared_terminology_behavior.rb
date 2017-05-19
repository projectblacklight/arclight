# frozen_string_literal: true

module Arclight
  ##
  # An extendable mixin intended to share terminology behavior between
  # the CustomDocument and CustomComponent classes
  module SharedTerminologyBehavior
    def add_unitid(t, prefix)
      t.unitid(path: prefix + 'did/unitid', index_as: %i[displayable searchable])
    end

    def add_extent(t, prefix)
      t.extent(path: prefix + 'did/physdesc/extent', index_as: %i[displayable searchable])
    end

    # date indexing
    def add_dates(t, prefix)
      t.normal_unit_dates(path: prefix + 'did/unitdate/@normal')
      t.unitdate_bulk(path: prefix + 'did/unitdate[@type=\'bulk\']', index_as: %i[displayable])
      t.unitdate_inclusive(path: prefix + 'did/unitdate[@type=\'inclusive\']', index_as: %i[displayable])
      t.unitdate_other(path: prefix + 'did/unitdate[not(@type)]', index_as: %i[displayable])
      t.unitdate(path: prefix + 'did/unitdate', index_as: %i[displayable])
    end

    def add_searchable_notes(t, prefix) # rubocop: disable Metrics/MethodLength
      # various searchable notes
      %i[
        accessrestrict
        accruals
        acqinfo
        altformavail
        appraisal
        arrangement
        bibliography
        bioghist
        custodhist
        fileplan
        note
        odd
        originalsloc
        otherfindaid
        phystech
        prefercite
        processinfo
        relatedmaterial
        scopecontent
        separatedmaterial
        userestrict
      ].each do |k|
        # many of the notes support various markup so we want everything but the heading
        t.send(k, path: "#{prefix}#{k}/*[local-name()!=\"head\"]", index_as: %i[displayable searchable])
      end

      # various searchable notes in the did
      %i[
        abstract
        materialspec
        physloc
      ].each do |k|
        t.send(k, path: "#{prefix}did/#{k}", index_as: %i[displayable searchable])
      end
      t.did_note(path: "#{prefix}did/note", index_as: %i[displayable searchable]) # conflicts with top-level note
    end
  end
end
