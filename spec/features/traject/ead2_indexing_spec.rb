# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'EAD 2 traject indexing' do
  subject(:result) do
    indexer.map_record(record)
  end

  let(:indexer) do
    Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(Arclight::Engine.root.join('lib/arclight/traject/ead2_config.rb'))
    end
  end
  let(:all_components) do
    components(result) - [result]
  end
  let(:fixture_path) do
    Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'sul-spec', 'a0011.xml')
  end
  let(:fixture_file) do
    File.read(fixture_path)
  end
  let(:nokogiri_reader) do
    Arclight::Traject::NokogiriNamespacelessReader.new(fixture_file.to_s, indexer.settings)
  end
  let(:records) do
    nokogiri_reader.to_a
  end
  let(:record) do
    records.first
  end

  def components(result)
    [result] + result.fetch('components', []).flat_map do |component|
      components(component)
    end
  end

  before do
    ENV['REPOSITORY_ID'] = nil
  end

  after do # ensure we reset these otherwise other tests will fail
    ENV['REPOSITORY_ID'] = nil
  end

  describe 'solr fields' do
    before do
      ENV['REPOSITORY_ID'] = 'sul-spec'
    end

    it 'id' do
      expect(result['id'].first).to eq 'a0011-xml'
      expect(result['ead_ssi'].first).to eq_ignoring_whitespace 'a0011.xml'
    end

    it 'title' do
      %w[title_ssm title_tesim].each do |field|
        expect(result[field]).to include_ignoring_whitespace 'Stanford University student life photograph album'
      end
      expect(result['normalized_title_ssm']).to include 'Stanford University student life photograph album, circa 1900-1906'
    end

    it 'level' do
      expect(result['level_ssm']).to eq ['collection']
      expect(result['level_ssim']).to eq ['Collection']
    end

    describe 'component_level_isim' do
      it 'is 0' do
        expect(result['component_level_isim']).to eq [0]
      end
    end

    describe 'sort_isi' do
      it 'is 0' do
        expect(result['sort_isi']).to eq [0]
      end
    end

    it 'dates' do
      expect(result['normalized_date_ssm']).to include_ignoring_whitespace 'circa 1900-1906'
      expect(result['unitdate_bulk_ssim']).to be_nil
      expect(result['unitdate_inclusive_ssm']).to include_ignoring_whitespace 'circa 1900-1906'
      expect(result['unitdate_other_ssim']).to be_nil
    end

    it 'creates date_range_ssim' do
      date_range = result['date_range_ssim']
      expect(date_range).to be_an Array
      expect(date_range.length).to eq 7
      expect(date_range.first).to eq 1900
      expect(date_range.last).to eq 1906
    end

    it 'repository' do
      %w[repository_ssim repository_ssm].each do |field|
        expect(result[field]).to include 'Stanford University Libraries. Special Collections and University Archives'
      end
    end

    it 'geogname' do
      %w[geogname_ssim geogname_ssm].each do |field|
        expect(result[field]).to include_ignoring_whitespace 'Yosemite National Park (Calif.)'
      end
    end

    it 'unitid' do
      expect(result['unitid_ssm']).to eq ['A0011']
    end

    it 'creator' do
      %w[creator_ssm creator_ssim creator_corpname_ssim creators_ssim creator_sort].each do |field|
        expect(result[field]).to equal_array_ignoring_whitespace ['Stanford University']
      end
    end

    it 'places' do
      expect(result['places_ssim']).to equal_array_ignoring_whitespace ['Yosemite National Park (Calif.)']
    end

    it 'has_online_content' do
      expect(result['has_online_content_ssim']).to eq [true]
    end

    it 'collection has normalized_title' do
      %w[collection_ssim collection_title_tesim].each do |field|
        expect(result[field]).to include_ignoring_whitespace 'Stanford University student life photograph album, circa 1900-1906'
      end
    end

    describe 'components' do
      let(:first_component) { all_components.first }

      it 'ref' do
        %w[ref_ssm ref_ssi].each do |field|
          expect(first_component[field]).to include 'aspace_ref6_lx4'
        end
      end

      it 'id' do
        expect(first_component).to include 'id' => ['a0011-xmlaspace_ref6_lx4']
      end

      it 'has_online_content' do
        expect(first_component['has_online_content_ssim']).to eq([true])
      end

      it 'digital_objects' do
        expect(first_component['digital_objects_ssm']).to eq(
          [
            JSON.generate(
              label: 'Photograph Album',
              href: 'http://purl.stanford.edu/kc844kt2526'
            )
          ]
        )
      end

      it 'geogname' do
        %w[geogname_ssim geogname_ssm].each do |field|
          expect(all_components.first[field]).to be_nil
        end
      end

      it 'collection has normalized title' do
        expect(first_component['collection_ssim']).to include_ignoring_whitespace 'Stanford University student life photograph album, circa 1900-1906'
      end

      it 'containers' do
        component = all_components.find { |c| c['ref_ssi'] == ['aspace_ref6_lx4'] }
        expect(component['containers_ssim']).to eq ['box 1']
      end

      describe 'levels' do
        let(:fixture_path) do
          Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'alphaomegaalpha.xml')
        end

        let(:level_component) { all_components.find { |c| c['ref_ssi'] == ['aspace_a951375d104030369a993ff943f61a77'] } }
        let(:other_level_component) { all_components.find { |c| c['ref_ssi'] == ['aspace_e6db65d47e891d61d69c2798c68a8f02'] } }

        it 'is the level Capitalized' do
          expect(level_component['level_ssm']).to eq(['Series'])
        end

        it 'is the otherlevel attribute when the level attribute is "otherlevel"' do
          expect(other_level_component['level_ssm']).to eq(['Binder'])
        end

        it 'sort' do
          expect(other_level_component['sort_isi']).to eq([3])
          expect(level_component['sort_isi']).to eq([33])
        end
      end

      it 'only indexes into fields that will support future atomic updates' do
        expect(result.keys).not_to include(/_sim$/)
        expect(result.keys).not_to include(/_ii$/)
        expect(result.keys).not_to include(/_teim$/)
      end
    end
  end

  describe 'large component list' do
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'sample', 'large-components-list.xml')
    end
    let(:nested_component) { all_components.find { |c| c['id'] == ['lc0100aspace_32ad9025a3a286358baeae91b5d7696e'] } }

    it 'builds the results' do
      expect(all_components.length).to eq 404
      expect(result['digital_objects_ssm']).to eq(
        [
          JSON.generate(
            label: '1st Street Arcade San Francisco',
            href: 'https://purl.stanford.edu/yy901zw2656'
          )
        ]
      )

      expect(nested_component['component_level_isim']).to eq [2]
      expect(nested_component['parent_ssim']).to eq %w[lc0100 aspace_327a75c226d44aa1a769edb4d2f13c6e]
      expect(nested_component['parent_ssi']).to eq ['aspace_327a75c226d44aa1a769edb4d2f13c6e']
      expect(nested_component['parent_unittitles_ssm']).to eq ['Large collection sample, 1843-1872', 'File 1']
    end
  end

  describe 'nested numbered c components' do
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'ncaids544-id-test.xml')
    end
    let(:component_with_descendants) { all_components.find { |c| c['id'] == ['ncaids544-testd0e452'] } }
    let(:nested_component) { all_components.find { |c| c['id'] == ['ncaids544-testd0e631'] } }

    it 'counts child components' do
      expect(component_with_descendants['child_component_count_isi']).to eq [9]
    end

    it 'correctly gets the component levels' do
      expect(nested_component['component_level_isim']).to eq [3]
    end
  end

  describe 'searchable notes' do
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'alphaomegaalpha.xml')
    end

    it 'builds the document' do
      expect(result['bioghist_html_tesm'].first).to match(/Alpha Omega Alpha Honor Medical Society was founded/)
      expect(result['bioghist_tesim'].second).to match(/Hippocratic oath/)
      expect(result['bioghist_heading_ssm'].first).to match(/^Historical Note/)
      expect(result['relatedmaterial_html_tesm'].first).to start_with('<p>An unprocessed collection includes')
      expect(result['abstract_html_tesm'].first).to match(/Alpha Omega Alpha Honor Medical Society/)
      expect(result['separatedmaterial_html_tesm'].first).to start_with('<p>Birth, Apollonius of Perga brain')
      expect(result['otherfindaid_html_tesm'].first).to start_with('<p>Li Europan lingues es membres del')
      expect(result['altformavail_html_tesm'].first).to start_with('<p>Rig Veda a mote of dust suspended')
      expect(result['originalsloc_html_tesm'].first).to start_with('<p>Something incredible is waiting')
      expect(result['arrangement_html_tesm'].first).to eq '<p>Arranged into seven series.</p>'
      expect(result['acqinfo_ssim'].first).to eq 'Donated by Alpha Omega Alpha.'
      expect(result['appraisal_html_tesm'].first).to start_with('<p>Corpus callosum something incredible')
      expect(result['custodhist_html_tesm'].first).to match(/Maintained by Alpha Omega Alpha and the family of William Root/)
      expect(result['processinfo_html_tesm'].first).to match(/Processed in 2001\. Descended from astronomers\./)
    end

    describe 'component-level' do
      it 'indexes own notes, not notes from descendants' do
        component = all_components.find { |c| c['id'] == ['aoa271aspace_563a320bb37d24a9e1e6f7bf95b52671'] }
        expect(component).to include 'scopecontent_html_tesm'
        expect(component['scopecontent_html_tesm']).to include(a_string_matching(/provide important background context./))
        expect(component['scopecontent_html_tesm']).not_to include(a_string_matching(/correspondence, and a nametag./))
      end

      it 'only indexes into fields that will support future atomic updates' do
        expect(all_components.flat_map(&:keys)).not_to include(/_sim$/)
        expect(all_components.flat_map(&:keys)).not_to include(/_ii$/)
        expect(all_components.flat_map(&:keys)).not_to include(/_teim$/)
      end
    end
  end

  describe 'alphaomegaalpha list' do
    let(:record) do
      Arclight::Traject::NokogiriNamespacelessReader.new(
        File.read(
          Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'alphaomegaalpha.xml')
        ).to_s,
        {}
      ).to_a.first
    end

    it 'extent at the collection level' do
      %w[extent_ssm extent_tesim].each do |field|
        expect(result[field]).to equal_array_ignoring_whitespace(
          ['15.0 linear feet (36 boxes + oversize folder)']
        )
      end
    end

    it 'extent at the component level' do
      component = all_components.find { |c| c['ref_ssi'] == ['aspace_a951375d104030369a993ff943f61a77'] }
      %w[extent_ssm extent_tesim].each do |field|
        expect(component[field]).to equal_array_ignoring_whitespace(
          ['1.5 Linear Feet']
        )
      end
    end

    it 'selects the components' do
      expect(all_components.length).to eq 38
    end

    context 'nested component' do
      describe 'accessrestrict' do
        context 'with its own accessrestrct' do
          let(:component_with_own_accessrestrict) do
            all_components.find { |c| c['ref_ssi'] == ['aspace_dba76dab6f750f31aa5fc73e5402e71d'] }
          end

          it 'has own accessrestrict' do
            expect(component_with_own_accessrestrict['accessrestrict_html_tesm'])
              .to include(a_string_matching(/Restricted until 2018./))
            expect(component_with_own_accessrestrict['parent_access_restrict_tesm'])
              .to include(a_string_matching(/No restrictions on access/))
          end
        end

        context 'with an accessrestrict on the parent' do
          let(:component_inheriting_accessrestrict_from_parent) do
            all_components.find { |c| c['ref_ssi'] == ['aspace_843e8f9f22bac69872d0802d6fffbb04'] }
          end

          it 'gets accessrestrict from parent component' do
            expect(component_inheriting_accessrestrict_from_parent['accessrestrict_html_tesm'])
              .to be_nil
            expect(component_inheriting_accessrestrict_from_parent['parent_access_restrict_tesm'])
              .to include(a_string_matching(/RESTRICTED: Access to these folders requires prior written approval./))
          end
        end

        context 'with an accessrestrict on the grandparent' do
          let(:component_inheriting_accessrestrict_from_grandparent) do
            all_components.find { |c| c['ref_ssi'] == ['aspace_4b4fa033c630a45d41fcd608cf0d184d'] }
          end

          it 'gets accessrestrict from grandparent component' do
            expect(component_inheriting_accessrestrict_from_grandparent['accessrestrict_html_tesm']).to be_nil
            expect(component_inheriting_accessrestrict_from_grandparent['parent_access_restrict_tesm'])
              .to include(a_string_matching(/RESTRICTED: Access to these folders requires prior written approval./))
          end
        end

        context 'with an accessrestrict on the collection' do
          let(:component_inheriting_accessrestrict_from_collection) do
            all_components.find { |c| c['ref_ssi'] == ['aspace_72f14d6c32e142baa3eeafdb6e4d69be'] }
          end

          it 'gets accessrestrict from collection' do
            expect(component_inheriting_accessrestrict_from_collection['accessrestrict_html_tesm']).to be_nil
            expect(component_inheriting_accessrestrict_from_collection['parent_access_restrict_tesm'])
              .to eq ['No restrictions on access.']
          end
        end
      end

      describe 'userestrict' do
        let(:component_with_own_userestrict) do
          all_components.find { |c| c['ref_ssi'] == ['aspace_72f14d6c32e142baa3eeafdb6e4d69be'] }
        end

        let(:component_inheriting_userestrict_from_collection) do
          all_components.find { |c| c['ref_ssi'] == ['aspace_dba76dab6f750f31aa5fc73e5402e71d'] }
        end

        it 'has own userestrict' do
          expect(component_with_own_userestrict['userestrict_html_tesm'])
            .to include(a_string_matching(/Original photographs must be handled using gloves/))
          expect(component_with_own_userestrict['parent_access_terms_tesm'])
            .to include(a_string_matching(/Original photographs must be handled using gloves./))
        end

        it 'gets userestrict from collection' do
          expect(component_inheriting_userestrict_from_collection['access_terms_ssm'])
            .to be_nil
          expect(component_inheriting_userestrict_from_collection['parent_access_terms_tesm'])
            .to include(a_string_matching(/Copyright was transferred to the public domain./))
        end
      end

      describe 'parents & titles' do
        let(:component_with_many_parents) { all_components.find { |c| c['ref_ssi'] == ['aspace_f934f1add34289f28bd0feb478e68275'] } }

        it 'parent_unittitles should be displayable and searchable' do
          component = all_components.find { |c| c['id'] == ['aoa271aspace_563a320bb37d24a9e1e6f7bf95b52671'] }
          %w[parent_unittitles_ssm parent_unittitles_tesim].each do |field|
            expect(component[field]).to contain_exactly(
              'Alpha Omega Alpha Archives, 1894-1992'
            )
          end
        end

        it 'parents are correctly ordered' do
          expect(component_with_many_parents['parent_ssim']).to eq %w[
            aoa271
            aspace_563a320bb37d24a9e1e6f7bf95b52671
            aspace_238a0567431f36f49acea49ef576d408
          ]
        end

        it 'parents and levels' do
          expect(component_with_many_parents['parent_levels_ssm']).to eq %w[
            collection
            Series
            Subseries
          ]
        end
      end
    end
  end

  describe 'containers in a component' do
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'alphaomegaalpha.xml')
    end

    it 'only indexes containers within a given component' do
      component = all_components.find { |c| c['id'] == ['aoa271aspace_843e8f9f22bac69872d0802d6fffbb04'] }
      expect(component['containers_ssim']).to eq ['box 1', 'folder 1']
    end

    it 'only indexes containers at the same level of the component' do
      component = all_components.find { |c| c['id'] == ['aoa271aspace_563a320bb37d24a9e1e6f7bf95b52671'] }
      expect(component['containers_ssim']).to be_nil
    end
  end

  describe 'subject elements' do
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'alphaomegaalpha.xml')
    end

    it 'indexes the values as controlled vocabulary terms' do
      %w[access_subjects_ssm access_subjects_ssim].each do |field|
        expect(result).to include field
        expect(result[field]).to contain_exactly(
          'Fraternizing',
          'Medicine',
          'Photographs',
          'Societies'
        )
      end
    end

    it 'indexes controlaccess subjects within a component' do
      component = all_components.find { |c| c['id'] == ['aoa271aspace_81c806b82a14c3c79d395bbd383b886f'] }
      %w[access_subjects_ssm access_subjects_ssim].each do |field|
        expect(component).to include field
        expect(component[field]).to contain_exactly 'Minutes'
      end
    end

    context 'with nested controlaccess subject elements' do
      let(:fixture_path) do
        Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'ncaids544-id-test.xml')
      end

      it 'indexes the values as controlled vocabulary terms' do
        %w[access_subjects_ssm access_subjects_ssim].each do |field|
          expect(result).to include field
          expect(result[field]).to equal_array_ignoring_whitespace(
            ['Acquired Immunodeficiency Syndrome',
             'African Americans',
             'Homosexuality',
             'Human Immunodeficiency Virus',
             'Public Health']
          )
        end
      end
    end
  end

  describe 'name elements' do
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'alphaomegaalpha.xml')
    end

    describe 'collection-level' do
      it 'indexes collection-level <controlaccess> names in their own field' do
        expect(result['names_coll_ssim']).to equal_array_ignoring_whitespace(
          ['Alpha Omega Alpha',
           'Root, William Webster, 1867-1932',
           'Bierring, Walter L. (Walter Lawrence), 1868-1961']
        )
      end

      it 'indexes all names at any level in a shared names field' do
        expect(result['names_ssim']).to include_ignoring_whitespace 'Root, William Webster, 1867-1932'
        expect(result['names_ssim']).to include_ignoring_whitespace 'Robertson\'s Crab House'
      end

      it 'indexes all names at any level in a type-specific name field' do
        expect(result['persname_ssim']).to include_ignoring_whitespace 'Anfinsen, Christian B.'
        expect(result['corpname_ssim']).to include_ignoring_whitespace 'Robertson\'s Crab House'
      end
    end

    describe 'component-level' do
      it 'indexes <controlaccess> names in a shared names field' do
        component = all_components.find { |c| c['id'] == ['aoa271aspace_843e8f9f22bac69872d0802d6fffbb04'] }
        expect(component).to include 'names_ssim'
        expect(component['names_ssim']).to include_ignoring_whitespace 'Robertson\'s Crab House'
      end

      it 'indexes names in fields for specific name types, regardless of <controlaccess>' do
        component = all_components.find { |c| c['id'] == ['aoa271aspace_843e8f9f22bac69872d0802d6fffbb04'] }
        expect(component['corpname_ssim']).to include_ignoring_whitespace 'Robertson\'s Crab House'
        expect(component['persname_ssim']).to include_ignoring_whitespace 'Anfinsen, Christian B.'
      end
    end
  end

  describe 'geognames' do
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'alphaomegaalpha.xml')
    end

    it 'indexes geognames' do
      component = all_components.find { |d| d['id'] == ['aoa271aspace_843e8f9f22bac69872d0802d6fffbb04'] }
      expect(component).to include 'geogname_ssim'
      expect(component['geogname_ssim']).to include('Popes Creek (Md.)')

      expect(component).to include 'geogname_ssm'
      expect(component['geogname_ssm']).to include('Popes Creek (Md.)')
    end
  end

  describe 'date ranges' do
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'alphaomegaalpha.xml')
    end

    it 'creates date_range_ssim' do
      component = all_components.find { |d| d['id'] == ['aoa271aspace_563a320bb37d24a9e1e6f7bf95b52671'] }
      date_range = component['date_range_ssim']
      expect(date_range).to be_an Array
      expect(date_range.length).to eq 75
      expect(date_range.first).to eq 1902
      expect(date_range.last).to eq 1976
    end
  end

  describe 'for documents with <acqinfo> elements' do
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'alphaomegaalpha.xml')
    end

    it 'indexes the values as stored facetable strings and multiple displayable strings' do
      expect(result).to include 'components'
      expect(all_components).not_to be_empty
      first_component = all_components.first

      expect(first_component).to include 'acqinfo_ssim'
      expect(first_component['acqinfo_ssim']).to contain_exactly(
        'Donated by Alpha Omega Alpha.'
      )

      expect(first_component).to include 'acqinfo_ssim'
      expect(first_component['acqinfo_ssim']).to contain_exactly(
        'Donated by Alpha Omega Alpha.'
      )
    end

    context 'when documents have <acqinfo> elements within <descgrp> elements' do
      let(:fixture_path) do
        Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'ncaids544-id-test.xml')
      end

      it 'indexes the values as stored facetable strings and multiple displayable strings' do
        expect(result).to include 'components'
        expect(all_components).not_to be_empty
        first_component = all_components.first

        expect(first_component).to include 'acqinfo_ssim'
        expect(first_component['acqinfo_ssim']).to equal_array_ignoring_whitespace(
          ["Gift, John L. Parascandola, PHS Historian's Office, 3/1/1994, Acc. #812. Gift, Donald Goldman, Acc. #2005-21."]
        )

        expect(first_component).to include 'acqinfo_ssim'
        expect(first_component['acqinfo_ssim']).to equal_array_ignoring_whitespace(
          ["Gift, John L. Parascandola, PHS Historian's Office, 3/1/1994, Acc. #812. Gift, Donald Goldman, Acc. #2005-21."]
        )
      end
    end
  end

  describe 'digital objects' do
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'nlm', 'alphaomegaalpha.xml')
    end

    context 'when <dao> is direct child of <c0x> component' do
      let(:component) { all_components.find { |c| c['id'] == ['aoa271aspace_e6db65d47e891d61d69c2798c68a8f02'] } }

      it 'gets the digital object' do
        expect(component['digital_objects_ssm']).to eq(
          [
            JSON.generate(
              label: 'Example diary',
              href: 'https://idn.duke.edu/ark:/87924/r3d39z'
            )
          ]
        )
      end
    end

    context 'when <dao> is child of the <did> in a <c0x> component' do
      let(:component) { all_components.find { |c| c['id'] == ['aoa271aspace_843e8f9f22bac69872d0802d6fffbb04'] } }

      it 'gets the digital objects' do
        expect(component['digital_objects_ssm']).to eq(
          [
            JSON.generate(
              label: 'Folder of digitized stuff',
              href: 'https://collections.nlm.nih.gov/bookviewer?PID=nlm:nlmuid-100957835-bk'
            ),
            JSON.generate(
              label: 'Letter from Christian B. Anfinsen (to the owner of the reel of yellow nylon rope [behind the bar])',
              href: 'https://profiles.nlm.nih.gov/ps/access/KKBBFL.pdf'
            )
          ]
        )
      end
    end
  end

  describe 'EAD without component IDs' do
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'sample', 'no-ids-recordgrp-level.xml')
    end
    let(:first_component) { all_components.first }
    let(:second_component) { all_components.second }

    it 'mints component ids by hashing absolute paths' do
      expect(result).to include 'components'
      expect(all_components).not_to be_empty

      expect(first_component['ref_ssi']).to contain_exactly('al_4bf70b448ac8351a147acff1dd8b1c0b9a791980')
      expect(first_component['id']).to contain_exactly('ehllHemingwayErnest-sampleal_4bf70b448ac8351a147acff1dd8b1c0b9a791980')

      expect(second_component['ref_ssi']).to contain_exactly('al_54b06e5ad77cab05ec7f6beeaca50022c47d9c7b')
      expect(second_component['id']).to contain_exactly('ehllHemingwayErnest-sampleal_54b06e5ad77cab05ec7f6beeaca50022c47d9c7b')

      expect(second_component['parent_ssim']).to equal_array_ignoring_whitespace(
        %w[ehllHemingwayErnest-sample al_4bf70b448ac8351a147acff1dd8b1c0b9a791980]
      )
    end
  end

  describe 'for EAD Documents without XML namespaces' do
    let(:fixture_without_namespaces) do
      doc = Nokogiri::XML.parse(fixture_file.to_s)
      doc.remove_namespaces!
      doc.to_xml
    end
    let(:nokogiri_reader) do
      Arclight::Traject::NokogiriNamespacelessReader.new(fixture_without_namespaces, indexer.settings)
    end

    it 'builds the document' do
      expect(result['id'].first).to eq_ignoring_whitespace 'a0011-xml'
      expect(result['ead_ssi'].first).to eq_ignoring_whitespace 'a0011.xml'

      %w[title_ssm title_tesim].each do |field|
        expect(result[field]).to include_ignoring_whitespace 'Stanford University student life photograph album'
      end
      expect(result['normalized_title_ssm']).to include_ignoring_whitespace 'Stanford University student life photograph album, circa 1900-1906'
    end
  end

  describe 'EAD top level is not "collection"' do
    let(:fixture_path) do
      Arclight::Engine.root.join('spec', 'fixtures', 'ead', 'sample', 'no-ids-recordgrp-level.xml')
    end

    it 'builds the level fields' do
      expect(result['level_ssm']).to eq ['collection']
      expect(result['level_ssim']).to eq ['Record Group', 'Collection']
    end
  end
end
