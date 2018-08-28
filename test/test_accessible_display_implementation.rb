# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'test/unit/assertions'

require File.join(
  File.dirname(File.dirname(__FILE__)),
  'lib',
  'hatemile',
  'implementation',
  'accessible_display_implementation'
)
require File.join(
  File.dirname(File.dirname(__FILE__)),
  'lib',
  'hatemile',
  'util',
  'configure'
)
require File.join(
  File.dirname(File.dirname(__FILE__)),
  'lib',
  'hatemile',
  'util',
  'html',
  'nokogiri',
  'nokogiri_html_dom_parser'
)

##
# Test methods of Hatemile::Implementation::AccessibleDisplayImplementation
# class.
class TestAccessibleDisplayImplementation < Test::Unit::TestCase
  ##
  # The name of attribute for not modify the elements.
  DATA_IGNORE = 'data-ignoreaccessibilityfix="true"'.freeze

  ##
  # The configuration of HaTeMiLe.
  CONFIGURE = Hatemile::Util::Configure.new.freeze

  ##
  # Test display_all_shortcuts method with container of shorcuts not defined.
  def test_display_all_shortcuts_container_not_defined
    html_parser = Hatemile::Util::Html::NokogiriLib::NokogiriHTMLDOMParser.new("
      <!DOCTYPE html>
      <html>
        <head>
          <title>HaTeMiLe Tests</title>
          <meta charset=\"UTF-8\" />
        </head>
        <body>
          <a href=\"https://github.com/hatemile/\" accesskey=\"r\">
            HaTeMiLe in Github
          </a>
          <a href=\"https://hatemile.github.io\" title=\"Site\" accesskey=\"w\">
            Webpage
          </a>
          <a href=\"http://localhost/\" #{DATA_IGNORE} accesskey=\"i\">
            Ignore link
          </a>
          <form action=\"\">
            <label for=\"field1\">Field1</label>
            <input type=\"text\" id=\"field1\" accesskey=\"f\" /><br />
            <input type=\"submit\" value=\"Submit\" accesskey=\"s\" />
          </form>
        </body>
      </html>
    ")
    display = Hatemile::Implementation::AccessibleDisplayImplementation.new(
      html_parser,
      CONFIGURE
    )
    display.display_all_shortcuts
    accesskey_r = html_parser.find('[accesskey="r"]').first_result
    accesskey_w = html_parser.find('[accesskey="w"]').first_result
    accesskey_f = html_parser.find('[accesskey="f"]').first_result
    accesskey_s = html_parser.find('[accesskey="s"]').first_result
    accesskey_i = html_parser.find('[accesskey="i"]').first_result
    reference_r = html_parser.find(
      '[data-attributeaccesskeyof="R"]'
    ).first_result
    reference_w = html_parser.find(
      '[data-attributeaccesskeyof="W"]'
    ).first_result
    reference_f = html_parser.find(
      '[data-attributeaccesskeyof="F"]'
    ).first_result
    reference_s = html_parser.find(
      '[data-attributeaccesskeyof="S"]'
    ).first_result
    reference_i = html_parser.find(
      '[data-attributeaccesskeyof="I"]'
    ).first_result
    shortcut_description_r = html_parser.find(accesskey_r).find_children(
      '[data-attributeaccesskeyof]'
    ).first_result
    shortcut_description_f = html_parser.find('[for="field1"]').find_children(
      '[data-attributeaccesskeyof]'
    ).first_result

    assert_not_nil(html_parser.find('#container-shortcuts-after').first_result)
    assert_equal('HaTeMiLe in Github', accesskey_r.get_attribute('title'))
    assert_equal('Site', accesskey_w.get_attribute('title'))
    assert_equal('Field1', accesskey_f.get_attribute('title'))
    assert_equal('Submit', accesskey_s.get_attribute('title'))
    assert(!accesskey_i.has_attribute?('title'))
    assert_equal(
      'ACCESS KEY PREFIX + R: HaTeMiLe in Github',
      reference_r.get_text_content
    )
    assert_equal('ACCESS KEY PREFIX + W: Site', reference_w.get_text_content)
    assert_equal('ACCESS KEY PREFIX + F: Field1', reference_f.get_text_content)
    assert_equal(
      'ACCESS KEY PREFIX + S: Submit',
      reference_s.get_text_content
    )
    assert_nil(reference_i)
    assert_equal(
      ' (Keyboard shortcut: ACCESS KEY PREFIX + R)',
      shortcut_description_r.get_text_content
    )
    assert_equal(
      ' (Keyboard shortcut: ACCESS KEY PREFIX + F)',
      shortcut_description_f.get_text_content
    )
  end

  ##
  # Test display_all_shortcuts method with container of shortcuts defined.
  def test_display_all_shortcuts_container_defined
    html_parser = Hatemile::Util::Html::NokogiriLib::NokogiriHTMLDOMParser.new("
      <!DOCTYPE html>
      <html>
        <head>
          <title>HaTeMiLe Tests</title>
          <meta charset=\"UTF-8\" />
        </head>
        <body>
          <div id=\"container-shortcuts-after\"></div>
          <a href=\"https://github.com/hatemile/\" accesskey=\"r\">
            HaTeMiLe in Github
          </a>
          <a href=\"https://hatemile.github.io\" title=\"Site\" accesskey=\"w\">
            Webpage
          </a>
          <a href=\"http://localhost/\" #{DATA_IGNORE} accesskey=\"i\">
            Ignore link
          </a>
          <form action=\"\">
            <label for=\"field1\">Field1</label>
            <input type=\"text\" id=\"field1\" accesskey=\"f\" /><br />
            <input type=\"submit\" value=\"Submit\" accesskey=\"s\" />
          </form>
        </body>
      </html>
    ")
    display = Hatemile::Implementation::AccessibleDisplayImplementation.new(
      html_parser,
      CONFIGURE
    )
    display.display_all_shortcuts
    accesskey_r = html_parser.find('[accesskey="r"]').first_result
    accesskey_w = html_parser.find('[accesskey="w"]').first_result
    accesskey_f = html_parser.find('[accesskey="f"]').first_result
    accesskey_s = html_parser.find('[accesskey="s"]').first_result
    accesskey_i = html_parser.find('[accesskey="i"]').first_result
    reference_r = html_parser.find(
      '#container-shortcuts-after [data-attributeaccesskeyof="R"]'
    ).first_result
    reference_w = html_parser.find(
      '#container-shortcuts-after [data-attributeaccesskeyof="W"]'
    ).first_result
    reference_f = html_parser.find(
      '#container-shortcuts-after [data-attributeaccesskeyof="F"]'
    ).first_result
    reference_s = html_parser.find(
      '#container-shortcuts-after [data-attributeaccesskeyof="S"]'
    ).first_result
    reference_i = html_parser.find(
      '#container-shortcuts-after [data-attributeaccesskeyof="I"]'
    ).first_result

    assert_equal(
      'container-shortcuts-after',
      html_parser.find(
        'body'
      ).first_result.get_first_element_child.get_attribute('id')
    )
    assert_equal('HaTeMiLe in Github', accesskey_r.get_attribute('title'))
    assert_equal('Site', accesskey_w.get_attribute('title'))
    assert_equal('Field1', accesskey_f.get_attribute('title'))
    assert_equal('Submit', accesskey_s.get_attribute('title'))
    assert(!accesskey_i.has_attribute?('title'))
    assert_equal(
      'ACCESS KEY PREFIX + R: HaTeMiLe in Github',
      reference_r.get_text_content
    )
    assert_equal('ACCESS KEY PREFIX + W: Site', reference_w.get_text_content)
    assert_equal('ACCESS KEY PREFIX + F: Field1', reference_f.get_text_content)
    assert_equal('ACCESS KEY PREFIX + S: Submit', reference_s.get_text_content)
    assert_nil(reference_i)
  end

  ##
  # Test display_all_roles method.
  def test_display_all_roles
    html_parser = Hatemile::Util::Html::NokogiriLib::NokogiriHTMLDOMParser.new("
      <!DOCTYPE html>
      <html role=\"application\">
        <head>
          <title>HaTeMiLe Tests</title>
          <meta charset=\"UTF-8\" />
        </head>
        <body>
          <a href=\"https://github.com/\" role=\"link\">Github</a>
          <span role=\"note\">Span</span>
          <label for=\"field1\">Field1</label>
          <input type=\"number\" id=\"field1\" role=\"spinbutton\" />
        </body>
      </html>
    ")
    display = Hatemile::Implementation::AccessibleDisplayImplementation.new(
      html_parser,
      CONFIGURE
    )
    display.display_all_roles
    body = html_parser.find('body').first_result
    a = html_parser.find('a').first_result
    span = html_parser.find('span[role="note"]').first_result
    index_span = body.get_children_elements.index(span)
    label = html_parser.find('label').first_result

    assert_equal(
      '(Begin of application) ',
      body.get_first_element_child.get_text_content
    )
    assert_equal(
      ' (End of application)',
      body.get_last_element_child.get_text_content
    )
    assert_equal('(Begin of link) ', a.get_first_element_child.get_text_content)
    assert_equal(' (End of link)', a.get_last_element_child.get_text_content)
    assert_equal(
      '(Begin of note) ',
      body.get_children_elements[index_span - 1].get_text_content
    )
    assert_equal(
      ' (End of note)',
      body.get_children_elements[index_span + 1].get_text_content
    )
    assert_equal(
      '(Begin of spin button) ',
      html_parser.find(label).find_children(
        '[data-roleof]'
      ).first_result.get_text_content
    )
    assert_equal(
      ' (End of spin button)',
      html_parser.find(label).find_children(
        '[data-roleof]'
      ).last_result.get_text_content
    )
  end

  ##
  # Test display_all_cell_headers method.
  def test_display_all_cell_headers
    html_parser = Hatemile::Util::Html::NokogiriLib::NokogiriHTMLDOMParser.new("
      <!DOCTYPE html>
      <html>
        <head>
          <title>HaTeMiLe Tests</title>
          <meta charset=\"UTF-8\" />
        </head>
        <body>
          <table>
            <thead>
              <tr>
                <th id=\"th1\">THEAD TH1</th>
                <th id=\"th2\">THEAD TH2</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td headers=\"th1\">TD1</td>
                <td headers=\"th2\">TD2</td>
              </tr>
              <tr>
                <th id=\"th3\">TH3</th>
                <td headers=\"th2 th3\">TD3</td>
              </tr>
            </tbody>
          </table>
        </body>
      </html>
    ")
    display = Hatemile::Implementation::AccessibleDisplayImplementation.new(
      html_parser,
      CONFIGURE
    )
    display.display_all_cell_headers
    td1 = html_parser.find('[headers="th1"]').first_result
    td3 = html_parser.find('[headers="th2 th3"]').first_result
    hc1 = html_parser.find(td1).find_children('[data-headersof]').first_result
    hc3 = html_parser.find(td3).find_children('[data-headersof]').first_result

    assert_not_nil(hc1)
    assert_not_nil(hc3)
    assert_equal('(Headers: THEAD TH1) ', hc1.get_text_content)
    assert_equal('(Headers: THEAD TH2 TH3) ', hc3.get_text_content)
  end

  ##
  # Test display_all_waiaria_states method.
  def test_display_all_waiaria_states
    html_parser = Hatemile::Util::Html::NokogiriLib::NokogiriHTMLDOMParser.new("
      <!DOCTYPE html>
      <html>
        <head>
          <title>HaTeMiLe Tests</title>
          <meta charset=\"UTF-8\" />
        </head>
        <body>
          <a aria-busy=\"true\">ARIA-BUSY</a>
          <a aria-checked=\"true\">ARIA-CHECKED</a>
          <a aria-dropeffect=\"copy\">ARIA-DROPEFFECT</a>
          <a aria-expanded=\"true\">ARIA-EXPANDED</a>
          <a aria-grabbed=\"true\">ARIA-GRABBED</a>
          <a aria-haspopup=\"true\">ARIA-HASPOPUP</a>
          <a aria-level=\"1\">ARIA-LEVEL</a>
          <a aria-orientation=\"vertical\">ARIA-ORIENTATION</a>
          <a aria-pressed=\"true\">ARIA-PRESSED</a>
          <a aria-selected=\"true\">ARIA-SELECTED</a>
          <a aria-sort=\"ascending\">ARIA-SORT</a>
          <a aria-required=\"true\">ARIA-REQUIRED</a>
          <a aria-valuemin=\"2\">ARIA-VALUEMIN</a>
          <a aria-valuemax=\"10\">ARIA-VALUEMAX</a>
          <a aria-autocomplete=\"both\">ARIA-AUTOCOMPLETE</a>
        </body>
      </html>
    ")
    display = Hatemile::Implementation::AccessibleDisplayImplementation.new(
      html_parser,
      CONFIGURE
    )
    display.display_all_waiaria_states
    aria_busy = html_parser.find('[aria-busy]').first_result
    aria_checked = html_parser.find('[aria-checked]').first_result
    aria_dropeffect = html_parser.find('[aria-dropeffect]').first_result
    aria_expanded = html_parser.find('[aria-expanded]').first_result
    aria_grabbed = html_parser.find('[aria-grabbed]').first_result
    aria_haspopup = html_parser.find('[aria-haspopup]').first_result
    aria_level = html_parser.find('[aria-level]').first_result
    aria_orientation = html_parser.find('[aria-orientation]').first_result
    aria_pressed = html_parser.find('[aria-pressed]').first_result
    aria_selected = html_parser.find('[aria-selected]').first_result
    aria_sort = html_parser.find('[aria-sort]').first_result
    aria_required = html_parser.find('[aria-required]').first_result
    aria_valuemin = html_parser.find('[aria-valuemin]').first_result
    aria_valuemax = html_parser.find('[aria-valuemax]').first_result
    aria_autocomplete = html_parser.find('[aria-autocomplete]').first_result
    span_busy = html_parser.find(aria_busy).find_children(
      '.force-read-before[data-ariabusyof]'
    ).first_result
    span_checked = html_parser.find(aria_checked).find_children(
      '.force-read-after[data-ariacheckedof]'
    ).first_result
    span_dropeffect = html_parser.find(aria_dropeffect).find_children(
      '.force-read-after[data-ariadropeffectof]'
    ).first_result
    span_expanded = html_parser.find(aria_expanded).find_children(
      '.force-read-after[data-ariaexpandedof]'
    ).first_result
    span_grabbed = html_parser.find(aria_grabbed).find_children(
      '.force-read-after[data-ariagrabbedof]'
    ).first_result
    span_haspopup = html_parser.find(aria_haspopup).find_children(
      '.force-read-after[data-ariahaspopupof]'
    ).first_result
    span_level = html_parser.find(aria_level).find_children(
      '.force-read-before[data-arialevelof]'
    ).first_result
    span_orientation = html_parser.find(aria_orientation).find_children(
      '.force-read-after[data-ariaorientationof]'
    ).first_result
    span_pressed = html_parser.find(aria_pressed).find_children(
      '.force-read-after[data-ariapressedof]'
    ).first_result
    span_selected = html_parser.find(aria_selected).find_children(
      '.force-read-after[data-ariaselectedof]'
    ).first_result
    span_sort = html_parser.find(aria_sort).find_children(
      '.force-read-before[data-ariasortof]'
    ).first_result
    span_required = html_parser.find(aria_required).find_children(
      '.force-read-after[data-attributerequiredof]'
    ).first_result
    span_valuemin = html_parser.find(aria_valuemin).find_children(
      '.force-read-after[data-attributevalueminof]'
    ).first_result
    span_valuemax = html_parser.find(aria_valuemax).find_children(
      '.force-read-after[data-attributevaluemaxof]'
    ).first_result
    span_autocomplete = html_parser.find(aria_autocomplete).find_children(
      '.force-read-after[data-ariaautocompleteof]'
    ).first_result

    assert_not_nil(span_busy)
    assert_not_nil(span_checked)
    assert_not_nil(span_dropeffect)
    assert_not_nil(span_expanded)
    assert_not_nil(span_grabbed)
    assert_not_nil(span_haspopup)
    assert_not_nil(span_level)
    assert_not_nil(span_orientation)
    assert_not_nil(span_pressed)
    assert_not_nil(span_selected)
    assert_not_nil(span_sort)
    assert_not_nil(span_required)
    assert_not_nil(span_valuemin)
    assert_not_nil(span_valuemax)
    assert_not_nil(span_autocomplete)
    assert_equal('(Updating) ', span_busy.get_text_content)
    assert_equal(' (Checked)', span_checked.get_text_content)
    assert_equal(' (Drop copy in target)', span_dropeffect.get_text_content)
    assert_equal(' (Expanded)', span_expanded.get_text_content)
    assert_equal(' (Dragging)', span_grabbed.get_text_content)
    assert_equal(' (Has popup)', span_haspopup.get_text_content)
    assert_equal('(Level: 1) ', span_level.get_text_content)
    assert_equal(' (Vertical orientation)', span_orientation.get_text_content)
    assert_equal(' (Pressed)', span_pressed.get_text_content)
    assert_equal(' (Selected)', span_selected.get_text_content)
    assert_equal('(Sorted ascending) ', span_sort.get_text_content)
    assert_equal(' (Required)', span_required.get_text_content)
    assert_equal(' (Minimum value: 2)', span_valuemin.get_text_content)
    assert_equal(' (Maximum value: 10)', span_valuemax.get_text_content)
    assert_equal(
      ' (List or inline autocomplete)',
      span_autocomplete.get_text_content
    )
  end

  ##
  # Test display_all_links_attributes method.
  def test_display_all_links_attributes
    html_parser = Hatemile::Util::Html::NokogiriLib::NokogiriHTMLDOMParser.new("
      <!DOCTYPE html>
      <html>
        <head>
          <title>HaTeMiLe Tests</title>
          <meta charset=\"UTF-8\" />
        </head>
        <body>
          <a id=\"l1\" href=\"https://github.com\" target=\"_blank\">Github</a>
          <a id=\"l2\" href=\"https://github.com/fluidicon.png\" download>
            Github icon
          </a>
        </body>
      </html>
    ")
    display = Hatemile::Implementation::AccessibleDisplayImplementation.new(
      html_parser,
      CONFIGURE
    )
    display.display_all_links_attributes
    link1 = html_parser.find('#l1 [data-attributetargetof]').first_result
    link2 = html_parser.find('#l2 [data-attributedownloadof]').first_result

    assert_not_nil(link1)
    assert_not_nil(link2)
    assert_equal('(Open this link in new tab) ', link1.get_text_content)
    assert_equal('(Download) ', link2.get_text_content)
  end

  ##
  # Test display_all_titles method.
  def test_display_all_titles
    html_parser = Hatemile::Util::Html::NokogiriLib::NokogiriHTMLDOMParser.new("
      <!DOCTYPE html>
      <html>
        <head>
          <title>HaTeMiLe Tests</title>
          <meta charset=\"UTF-8\" />
        </head>
        <body>
          <a href=\"https://github.com/\" title=\"Link\">Github</a>
          <span title=\"Text\">Span</span>
          <label for=\"field1\">Field1</label>
          <input type=\"number\" id=\"field1\" title=\"Spin button\" />
        </body>
      </html>
    ")
    display = Hatemile::Implementation::AccessibleDisplayImplementation.new(
      html_parser,
      CONFIGURE
    )
    display.display_all_titles
    body = html_parser.find('body').first_result
    link = html_parser.find('a [data-attributetitleof]').first_result
    span = html_parser.find('span[title]').first_result
    index_span = body.get_children_elements.index(span)
    input = html_parser.find('label [data-attributetitleof]').first_result

    assert_not_nil(link)
    assert_not_nil(input)
    assert_equal('(Title: Link) ', link.get_text_content)
    assert_equal(
      '(Title: Text) ',
      body.get_children_elements[index_span - 1].get_text_content
    )
    assert_equal('(Title: Spin button) ', input.get_text_content)
  end

  ##
  # Test display_all_languages method.
  def test_display_all_languages
    html_parser = Hatemile::Util::Html::NokogiriLib::NokogiriHTMLDOMParser.new("
      <!DOCTYPE html>
      <html lang=\"en\">
        <head>
          <title>HaTeMiLe Tests</title>
          <meta charset=\"UTF-8\" />
        </head>
        <body>
          <a href=\"https://es.wikipedia.org/\" hreflang=\"es\">
            Wikipedia
          </a>
          <span lang=\"pt-br\">Texto</span>
          <label for=\"field1\">Contrôle1</label>
          <input type=\"text\" id=\"field1\" lang=\"fr\" />
        </body>
      </html>
    ")
    display = Hatemile::Implementation::AccessibleDisplayImplementation.new(
      html_parser,
      CONFIGURE
    )
    display.display_all_languages
    body = html_parser.find('body').first_result
    a = html_parser.find('a').first_result
    span = html_parser.find('span[lang="pt-br"]').first_result
    index_span = body.get_children_elements.index(span)
    label = html_parser.find('label').first_result

    assert_equal(
      '(Begin of language: English) ',
      body.get_first_element_child.get_text_content
    )
    assert_equal(
      ' (End of language: English)',
      body.get_last_element_child.get_text_content
    )
    assert_equal(
      '(Begin of language: Spanish) ',
      a.get_first_element_child.get_text_content
    )
    assert_equal(
      ' (End of language: Spanish)',
      a.get_last_element_child.get_text_content
    )
    assert_equal(
      '(Begin of language: Portuguese) ',
      body.get_children_elements[index_span - 1].get_text_content
    )
    assert_equal(
      ' (End of language: Portuguese)',
      body.get_children_elements[index_span + 1].get_text_content
    )
    assert_equal(
      '(Begin of language: French) ',
      html_parser.find(label).find_children(
        '[data-languageof]'
      ).first_result.get_text_content
    )
    assert_equal(
      ' (End of language: French)',
      html_parser.find(label).find_children(
        '[data-languageof]'
      ).last_result.get_text_content
    )
  end
end
