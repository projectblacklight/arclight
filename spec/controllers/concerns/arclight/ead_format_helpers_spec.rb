# frozen_string_literal: true

require 'spec_helper'

class TestController
  include Arclight::EadFormatHelpers
  include ActionView::Helpers::TagHelper
end

RSpec.describe Arclight::EadFormatHelpers do
  subject(:helper) { TestController.new }

  describe '#render_html_tags' do
    describe 'sanitizes markup' do
      it 'strips out scripts' do
        content = helper.render_html_tags(value: ['<p onclick="do_bad_things();">Hello</p>'])
        expect(content).to eq_ignoring_whitespace '<p>Hello</p>'
      end

      it 'strips out non-html tags but keeps the content' do
        content = helper.render_html_tags(value: ['<bibref>Affiches americaines. San Domingo: Imprimerie royale du Cap, 1782. Nos. 30, 35.</bibref>'])
        expect(content).to eq_ignoring_whitespace 'Affiches americaines. San Domingo: Imprimerie royale du Cap, 1782. Nos. 30, 35.'
      end
    end

    describe 'multi-value field separation' do
      it 'wraps multi-value fields in <p> if unwrapped' do
        content = helper.render_html_tags(value: %w[Hello world])
        expect(content).to eq_ignoring_whitespace '<p>Hello</p><p>world</p>'
      end

      it 'does not wrap in value in <p> if already wrapped' do
        content = helper.render_html_tags(value: %w[<p>Hello</p> <p>world</p>])
        expect(content).to eq_ignoring_whitespace '<p>Hello</p><p>world</p>'
      end

      it 'keeps single-value fields unwrapped' do
        content = helper.render_html_tags(value: %w[Hello])
        expect(content).to eq_ignoring_whitespace 'Hello'
      end
    end

    describe 'nodes with @render attributes' do
      it 'altrender custom -> html class' do
        content = helper.render_html_tags(value: ['<emph render="altrender" altrender="my-custom-class">special text</emph>'])
        expect(content).to eq '<span class="my-custom-class">special text</span>'
      end

      it 'bold -> strong' do
        content = helper.render_html_tags(value: ['I <emph render="bold">strongly</emph> suggest'])
        expect(content).to eq 'I <strong>strongly</strong> suggest'
      end

      it 'bolddoublequote -> strong & wrapped' do
        content = helper.render_html_tags(value: ['<emph render="bolddoublequote">a strong quote</emph>'])
        expect(content).to eq '<strong>"a strong quote"</strong>'
      end

      it 'bolditalic -> strong & em' do
        content = helper.render_html_tags(value: ['<emph render="bolditalic">strong emphasis</emph>'])
        expect(content).to eq '<em><strong>strong emphasis</strong></em>'
      end

      it 'boldsinglequote -> strong' do
        content = helper.render_html_tags(value: ['<emph render="boldsinglequote">this seems rare</emph>'])
        expect(content).to eq '<strong>\'this seems rare\'</strong>'
      end

      it 'boldsmcaps -> small & strong w/class' do
        content = helper.render_html_tags(value: ['<emph render="boldsmcaps">doctoral research</emph>'])
        expect(content).to eq '<small><strong class="text-uppercase">doctoral research</strong></small>'
      end

      it 'boldunderline -> strong w/class' do
        content = helper.render_html_tags(value: ['<emph render="boldunderline">human potential</emph>'])
        expect(content).to eq '<strong class="text-underline">human potential</strong>'
      end

      it 'doublequote -> wrapped in quotes' do
        content = helper.render_html_tags(value: ['This is <emph render="doublequote">useful</emph>.'])
        expect(content).to eq 'This is <span>"useful"</span>.'
      end

      it 'italic -> em' do
        content = helper.render_html_tags(value: ['Smith was not the <emph render="italic">only</emph> guilty party.'])
        expect(content).to eq 'Smith was not the <em>only</em> guilty party.'
      end

      it 'nonproport -> em' do
        content = helper.render_html_tags(value: ['<emph render="nonproport">hello</emph>'])
        expect(content).to eq '<em>hello</em>'
      end

      it 'singlequote -> wrapped in quotes' do
        content = helper.render_html_tags(value: ['This is <emph render="singlequote">useful</emph>.'])
        expect(content).to eq 'This is <span>\'useful\'</span>.'
      end

      it 'smcaps -> small w/class' do
        content = helper.render_html_tags(value: ['<emph render="smcaps">excerpted</emph>'])
        expect(content).to eq '<small class="text-uppercase">excerpted</small>'
      end

      it 'sub -> sub' do
        content = helper.render_html_tags(value: ['H<emph render="sub">2</emph>O'])
        expect(content).to eq 'H<sub>2</sub>O'
      end

      it 'super -> sup' do
        content = helper.render_html_tags(value: ['E = mc<emph render="super">2</emph>'])
        expect(content).to eq 'E = mc<sup>2</sup>'
      end

      it 'underline -> span w/class' do
        content = helper.render_html_tags(value: ['The <emph render="underline">Mona Lisa</emph> hangs in the Louvre.'])
        expect(content).to eq 'The <span class="text-underline">Mona Lisa</span> hangs in the Louvre.'
      end
    end

    describe 'lists' do
      describe 'basic unordered lists' do
        it 'untyped list -> ul' do
          content = helper.render_html_tags(value: ['<list><item>One</item><item>Two</item></list>'])
          expect(content).to eq_ignoring_whitespace '<ul><li>One</li><li>Two</li></ul>'
        end

        it 'simple list -> ul' do
          content = helper.render_html_tags(value: ['<list type="simple"><item>One</item><item>Two</item></list>'])
          expect(content).to eq_ignoring_whitespace '<ul><li>One</li><li>Two</li></ul>'
        end

        it 'marked list -> ul' do
          content = helper.render_html_tags(value: ['<list type="marked"><item>One</item><item>Two</item></list>'])
          expect(content).to eq_ignoring_whitespace '<ul><li>One</li><li>Two</li></ul>'
        end

        it 'list with head -> ul' do
          content = helper.render_html_tags(value: ['<list><head>My List</head><item>One</item><item>Two</item></list>'])
          expect(content).to eq_ignoring_whitespace '<div class="list-head">My List</div><ul><li>One</li><li>Two</li></ul>'
        end
      end

      describe 'ordered lists' do
        it 'ordered list -> ol' do
          content = helper.render_html_tags(value: ['<list type="ordered"><item>One</item><item>Two</item></list>'])
          expect(content).to eq_ignoring_whitespace '<ol><li>One</li><li>Two</li></ol>'
        end
      end

      describe 'lists with render attributes inside' do
        it 'transforms nested markup' do
          content = helper.render_html_tags(value: ['<list type="ordered">
            <item>Item <emph render="bold">One</emph></item><item>Item <title render="italic">Two</title></item></list>'])
          expect(content).to eq_ignoring_whitespace '<ol><li>Item <strong>One</strong></li><li>Item <em>Two</em></li></ol>'
        end
      end

      describe 'nested lists' do
        it 'transforms hierarchical nested lists' do
          content = helper.render_html_tags(value: [%(
            <list type="ordered">
              <head>Summary Contents List</head>
              <item>Chronological, mainly 1920-1966
                <list type="simple">
                  <item>Joseph Maddy</item>
                  <item>Camp History
                    <list type="simple">
                      <item>Histories and anniversaries</item>
                      <item>Orchestra Camp Colony</item>
                    </list>
                  </item>
                  <item>Camp records, 1935-1945</item>
                  <item>Camp records, 1945-1966</item>
                </list>
              </item>
              <item>Previously Closed Files</item>
            </list>
          )])
          expect(content).to eq_ignoring_whitespace %(
            <div class="list-head">Summary Contents List</div>
            <ol>
              <li>Chronological, mainly 1920-1966
                <ul>
                  <li>Joseph Maddy</li>
                  <li>Camp History
                    <ul>
                      <li>Histories and anniversaries</li>
                      <li>Orchestra Camp Colony</li>
                    </ul>
                  </li>
                  <li>Camp records, 1935-1945</li>
                  <li>Camp records, 1945-1966</li>
                </ul>
              </li>
              <li>Previously Closed Files</li>
            </ol>
          )
        end
      end
    end

    describe 'definition lists' do
      describe 'basic deflists without column headers' do
        it 'deflist -> dl' do
          content = helper.render_html_tags(value: [%(
            <list type="deflist">
              <defitem>
                <label>AL</label>
                <item>Alabama</item>
              </defitem>
              <defitem>
                <label>AK</label>
                <item>Alaska</item>
              </defitem>
              <defitem>
                <label>AZ</label>
                <item>Arizona</item>
              </defitem>
            </list>
          )])
          expect(content).to eq_ignoring_whitespace %(
            <dl class="deflist">
              <dt>AL</dt>
              <dd>Alabama</dd>
              <dt>AK</dt>
              <dd>Alaska</dd>
              <dt>AZ</dt>
              <dd>Arizona</dd>
            </dl>
          )
        end
      end

      describe 'deflists with column headers' do
        it 'deflist -> table' do
          content = helper.render_html_tags(value: [%(
            <list type="deflist">
              <listhead>
                <head01>Abbreviation</head01>
                <head02>Expansion</head02>
              </listhead>
              <defitem>
                <label>ALS</label>
                <item>Autograph Letter Signed</item>
              </defitem>
              <defitem>
                <label>TLS</label>
                <item>Typewritten Letter Signed</item>
              </defitem>
            </list>
          )])
          expect(content).to eq_ignoring_whitespace %(
            <table class="table deflist">
              <thead>
                <tr>
                  <th>Abbreviation</th>
                  <th>Expansion</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>ALS</td>
                  <td>Autograph Letter Signed</td>
                </tr>
                <tr>
                  <td>TLS</td>
                  <td>Typewritten Letter Signed</td>
                </tr>
              </tbody>
            </table>
          )
        end
      end
    end

    describe 'chronlists' do
      describe 'basic chronlist without custom headers or eventgrps' do
        it 'chronlist -> table w/default headers' do
          content = helper.render_html_tags(value: [%(
            <chronlist>
              <head>Julia Stockton Rush</head>
              <chronitem>
                <date>1759</date>
                <event>Born, at "Morven" family estate near Princeton, N.J.</event>
              </chronitem>
              <chronitem>
                <date>1776</date>
                <event>Married Benjamin Rush; the couple went on to have 13 children</event>
              </chronitem>
            </chronlist>
          )])
          expect(content).to eq_ignoring_whitespace %(
          <table class="table chronlist">
            <caption class="chronlist-head">Julia Stockton Rush</caption>
            <thead>
              <tr>
                <th>Date</th>
                <th>Event</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td class="chronlist-item-date">1759</td>
                <td class="chronlist-item-event">Born, at "Morven" family estate near Princeton, N.J.</td>
              </tr>
              <tr>
                <td class="chronlist-item-date">1776</td>
                <td class="chronlist-item-event">Married Benjamin Rush; the couple went on to have 13 children</td>
              </tr>
            </tbody>
          </table>
          )
        end
      end

      describe 'chronlist with custom headers & multi events in eventgrps' do
        it 'chronlist -> table w/custom headers' do
          content = helper.render_html_tags(value: [%(
            <chronlist>
              <head>Benjamin Rush</head>
              <listhead>
                <head01>Specific Dates</head01>
                <head02>Things That Happened</head02>
              </listhead>
              <chronitem>
                <date>1769</date>
                <eventgrp>
                  <event>Began medical practice in Philadelphia</event>
                  <event>Appointed Professor of Chemistry in College of Philadelphia's medical
                      department</event>
                </eventgrp>
              </chronitem>
              <chronitem>
                <date>1776</date>
                <eventgrp>
                  <event>Took his seat in Second Continental Congress</event>
                </eventgrp>
              </chronitem>
            </chronlist>
          )])
          expect(content).to eq_ignoring_whitespace %(
          <table class="table chronlist">
            <caption class="chronlist-head">Benjamin Rush</caption>
            <thead>
              <tr>
                <th>Specific Dates</th>
                <th>Things That Happened</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td class="chronlist-item-date">1769</td>
                <td class="chronlist-item-event">
                  <div>Began medical practice in Philadelphia</div>
                  <div>Appointed Professor of Chemistry in College of Philadelphia's medical department</div>
                </td>
              </tr>
              <tr>
                <td class="chronlist-item-date">1776</td>
                <td class="chronlist-item-event">
                  <div>Took his seat in Second Continental Congress</div>
                </td>
              </tr>
            </tbody>
          </table>
          )
        end
      end
    end
  end
end
