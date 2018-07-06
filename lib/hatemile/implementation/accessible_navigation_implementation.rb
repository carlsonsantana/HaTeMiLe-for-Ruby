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

require File.dirname(__FILE__) + '/../accessible_navigation.rb'
require File.dirname(__FILE__) + '/../util/skipper.rb'

module Hatemile
  module Implementation
    ##
    # The AccessibleNavigationImplementation class is official implementation of
    # AccessibleNavigation interface.
    class AccessibleNavigationImplementation < AccessibleNavigation
      public_class_method :new

      protected

      ##
      # Returns the description of element.
      #
      # ---
      #
      # Parameters:
      #  1. Hatemile::Util::HTMLDOMElement +element+ The element with description.
      # Return:
      # String The description of element.
      def getDescription(element)
        description = nil
        if element.hasAttribute?('title')
          description = element.getAttribute('title')
        elsif element.hasAttribute?('aria-label')
          description = element.getAttribute('aria-label')
        elsif element.hasAttribute?('alt')
          description = element.getAttribute('alt')
        elsif element.hasAttribute?('label')
          description = element.getAttribute('label')
        elsif element.hasAttribute?('aria-labelledby') || element.hasAttribute?('aria-describedby')
          if element.hasAttribute?('aria-labelledby')
            descriptionIds = element.getAttribute('aria-labelledby').split(/[ \n\t\r]+/)
          else
            descriptionIds = element.getAttribute('aria-describedby').split(/[ \n\t\r]+/)
          end
          descriptionIds.each do |descriptionId|
            elementDescription = @parser.find("##{descriptionId}").firstResult
            unless elementDescription.nil?
              description = elementDescription.getTextContent
              break
            end
          end
        elsif (element.getTagName == 'INPUT') && element.hasAttribute?('type')
          type = element.getAttribute('type').downcase
          if ((type == 'button') || (type == 'submit') || (type == 'reset')) && element.hasAttribute?('value')
            description = element.getAttribute('value')
          end
        end
        description = element.getTextContent if description.nil?
        description.gsub(/[ \n\t\r]+/, ' ')
      end

      ##
      # Generate the list of shortcuts of page.
      #
      # ---
      #
      # Return:
      # Hatemile::Util::HTMLDOMElement The list of shortcuts of page.
      def generateListShortcuts
        container = @parser.find("##{@idContainerShortcuts}").firstResult

        htmlList = nil
        if container.nil?
          local = @parser.find('body').firstResult
          unless local.nil?
            container = @parser.createElement('div')
            container.setAttribute('id', @idContainerShortcuts)

            textContainer = @parser.createElement('span')
            textContainer.setAttribute('id', @idTextShortcuts)
            textContainer.appendText(@textShortcuts)

            container.appendElement(textContainer)
            local.appendElement(container)

            executeFixSkipper(container)
            executeFixSkipper(textContainer)
          end
        end
        unless container.nil?
          htmlList = @parser.find(container).findChildren('ul').firstResult
          if htmlList.nil?
            htmlList = @parser.createElement('ul')
            container.appendElement(htmlList)
          end
          executeFixSkipper(htmlList)
        end
        @listShortcutsAdded = true

        htmlList
      end

      ##
      # Generate the list of skippers of page.
      #
      # ---
      #
      # Return:
      # Hatemile::Util::HTMLDOMElement The list of skippers of page.
      def generateListSkippers
        container = @parser.find("##{@idContainerSkippers}").firstResult
        htmlList = nil
        if container.nil?
          local = @parser.find('body').firstResult
          unless local.nil?
            container = @parser.createElement('div')
            container.setAttribute('id', @idContainerSkippers)
            local.getFirstElementChild.insertBefore(container)
          end
        end
        unless container.nil?
          htmlList = @parser.find(container).findChildren('ul').firstResult
          if htmlList.nil?
            htmlList = @parser.createElement('ul')
            container.appendElement(htmlList)
          end
        end
        @listSkippersAdded = true

        htmlList
      end

      ##
      # Generate the list of heading links of page.
      #
      # ---
      #
      # Return:
      # Hatemile::Util::HTMLDOMElement The list of heading links of page.
      def generateListHeading
        container = @parser.find("##{@idContainerHeading}").firstResult
        htmlList = nil
        if container.nil?
          local = @parser.find('body').firstResult
          unless local.nil?
            container = @parser.createElement('div')
            container.setAttribute('id', @idContainerHeading)

            textContainer = @parser.createElement('span')
            textContainer.setAttribute('id', @idTextHeading)
            textContainer.appendText(@textHeading)

            container.appendElement(textContainer)
            local.appendElement(container)

            executeFixSkipper(container)
            executeFixSkipper(textContainer)
          end
        end
        unless container.nil?
          htmlList = @parser.find(container).findChildren('ol').firstResult
          if htmlList.nil?
            htmlList = @parser.createElement('ol')
            container.appendElement(htmlList)
          end
          executeFixSkipper(htmlList)
        end
        htmlList
      end

      ##
      # Returns the level of heading.
      #
      # ---
      #
      # Parameters:
      #  1. Hatemile::Util::HTMLDOMElement +element+ The heading.
      # Return:
      # Integer The level of heading.
      def getHeadingLevel(element)
        tag = element.getTagName
        if tag == 'H1'
          return 1
        elsif tag == 'H2'
          return 2
        elsif tag == 'H3'
          return 3
        elsif tag == 'H4'
          return 4
        elsif tag == 'H5'
          return 5
        elsif tag == 'H6'
          return 6
        end
        -1
      end

      ##
      # Inform if the headings of page are sintatic correct.
      #
      # ---
      #
      # Return:
      # Boolean True if the headings of page are sintatic correct or false if not.
      def isValidHeading
        elements = @parser.find('h1,h2,h3,h4,h5,h6').listResults
        lastLevel = 0
        countMainHeading = 0
        validateHeading = true
        elements.each do |element|
          level = getHeadingLevel(element)
          if level == 1
            if countMainHeading == 1
              return false
            else
              countMainHeading = 1
            end
          end
          return false if (level - lastLevel) > 1
          lastLevel = level
        end
        true
      end

      ##
      # Generate an anchor for the element.
      #
      # ---
      #
      # Parameters:
      #  1. Hatemile::Util::HTMLDOMElement +element+ The element.
      #  2. String +dataAttribute+ The name of attribute that links the element with
      #   the anchor.
      #  3. String +anchorClass+ The HTML class of anchor.
      # Return:
      # Hatemile::Util::HTMLDOMElement The anchor.
      def generateAnchorFor(element, dataAttribute, anchorClass)
        Hatemile::Util::CommonFunctions.generateId(element, @prefixId)
        anchor = nil
        if @parser.find("[#{dataAttribute}=\"#{element.getAttribute('id')}\"]").firstResult.nil?
          if element.getTagName == 'A'
            anchor = element
          else
            anchor = @parser.createElement('a')
            Hatemile::Util::CommonFunctions.generateId(anchor, @prefixId)
            anchor.setAttribute('class', anchorClass)
            element.insertBefore(anchor)
          end
          unless anchor.hasAttribute?('name')
            anchor.setAttribute('name', anchor.getAttribute('id'))
          end
          anchor.setAttribute(dataAttribute, element.getAttribute('id'))
        end
        anchor
      end

      ##
      # Replace the shortcut of elements, that has the shortcut passed.
      #
      # ---
      #
      # Parameters:
      #   1. String +shortcut+ The shortcut.
      def freeShortcut(shortcut)
        found = false
        alphaNumbers = '1234567890abcdefghijklmnopqrstuvwxyz'
        elements = @parser.find('[accesskey]').listResults
        elements.each do |element|
          shortcuts = element.getAttribute('accesskey').downcase;
          if Hatemile::Util::CommonFunctions.inList(shortcuts, shortcut)
            (0..alphaNumbers.length - 1).each do |i|
              key = alphaNumbers[i, i + 1]
              found = true
              elements.each do |elementWithShortcuts|
                shortcuts = elementWithShortcuts.getAttribute('accesskey').downcase
                if Hatemile::Util::CommonFunctions.inList(shortcuts, key)
                  found = false
                  break
                end
              end
              if found
                element.setAttribute('accesskey', key)
                break
              end
            end
            break if found
          end
        end
      end

      ##
      # Call fixSkipper method for element, if the page has the container of
      # skippers.
      #
      # ---
      #
      # Parameters:
      #  1. Hatemile::Util::HTMLDOMElement +element+ The element.
      def executeFixSkipper(element)
        unless @listSkippers.nil?
          @skippers.each do |skipper|
            if @parser.find(skipper.getSelector).listResults.include?(element)
              fixSkipper(element, skipper)
            end
          end
        end
      end

      ##
      # Call fixShortcut method for element, if the page has the container of
      # shortcuts.
      #
      # ---
      #
      # Parameters:
      #  1. Hatemile::Util::HTMLDOMElement +element+ The element.
      def executeFixShortcut(element)
        fixShortcut(element) unless @listShortcuts.nil?
      end

      public

      ##
      # Initializes a new object that manipulate the accessibility of the
      # navigation of parser.
      #
      # ---
      #
      # Parameters:
      #  1. Hatemile::Util::HTMLDOMParser +parser+ The HTML parser.
      #  2. Hatemile::Util::Configure +configure+ The configuration of HaTeMiLe.
      #  3. String +userAgent+ The user agent of the user.
      def initialize(parser, configure, userAgent = nil)
        @parser = parser
        @idContainerShortcuts = 'container-shortcuts'
        @idContainerSkippers = 'container-skippers'
        @idContainerHeading = 'container-heading'
        @idTextShortcuts = 'text-shortcuts'
        @idTextHeading = 'text-heading'
        @classSkipperAnchor = 'skipper-anchor'
        @classHeadingAnchor = 'heading-anchor'
        @dataAccessKey = 'data-shortcutdescriptionfor'
        @dataIgnore = 'data-ignoreaccessibilityfix'
        @dataAnchorFor = 'data-anchorfor'
        @dataHeadingAnchorFor = 'data-headinganchorfor'
        @dataHeadingLevel = 'data-headinglevel'
        @prefixId = configure.getParameter('prefix-generated-ids')
        @textShortcuts = configure.getParameter('text-shortcuts')
        @textHeading = configure.getParameter('text-heading')
        @standartPrefix = configure.getParameter('text-standart-shortcut-prefix')
        @skippers = configure.getSkippers
        @listShortcutsAdded = false
        @listSkippersAdded = false
        @validateHeading = false
        @validHeading = false
        @listSkippers = nil
        @listShortcuts = nil

        unless userAgent.nil?
          userAgent = userAgent.downcase
          opera = userAgent.include?('opera')
          mac = userAgent.include?('mac')
          konqueror = userAgent.include?('konqueror')
          spoofer = userAgent.include?('spoofer')
          safari = userAgent.include?('applewebkit')
          windows = userAgent.include?('windows')
          chrome = userAgent.include?('chrome')
          firefox = !userAgent.match('firefox/[2-9]|minefield/3').nil?
          ie = userAgent.include?('msie') || userAgent.include?('trident')

          if opera
            @prefix = 'SHIFT + ESC'
          elsif chrome && mac && !spoofer
            @prefix = 'CTRL + OPTION'
          elsif safari && !windows && !spoofer
            @prefix = 'CTRL + ALT'
          elsif !windows && (safari || mac || konqueror)
            @prefix = 'CTRL'
          elsif firefox
            @prefix = 'ALT + SHIFT'
          elsif chrome || ie
            @prefix = 'ALT'
          else
            @prefix = @standartPrefix
          end
        else
          @prefix = @standartPrefix
        end
      end

      def fixShortcut(element)
        if element.hasAttribute?('accesskey')
          description = getDescription(element)
          unless element.hasAttribute?('title')
            element.setAttribute('title', description)
          end

          @listShortcuts = generateListShortcuts unless @listShortcutsAdded

          unless @listShortcuts.nil?
            keys = element.getAttribute('accesskey').split(/[ \n\t\r]+/)
            keys.each do |key|
              key = key.upcase
              if @parser.find(@listShortcuts).findChildren("[#{@dataAccessKey}=\"#{key}\"]").firstResult.nil?
                item = @parser.createElement('li')
                item.setAttribute(@dataAccessKey, key)
                item.appendText("#{@prefix} + #{key}: #{description}")
                @listShortcuts.appendElement(item)
              end
            end
          end
        end
      end

      def fixShortcuts
        elements = @parser.find('[accesskey]').listResults
        elements.each do |element|
          fixShortcut(element) unless element.hasAttribute?(@dataIgnore)
        end
      end

      def fixSkipper(element, skipper)
        @listSkippers = generateListSkippers unless @listSkippersAdded
        unless @listSkippers.nil?
          anchor = generateAnchorFor(element, @dataAnchorFor, @classSkipperAnchor)
          unless anchor.nil?
            itemLink = @parser.createElement('li')
            link = @parser.createElement('a')
            link.setAttribute('href', "##{anchor.getAttribute('name')}")
            link.appendText(skipper.getDefaultText)

            shortcuts = skipper.getShortcuts
            unless shortcuts.empty?
              shortcut = shortcuts[0]
              unless shortcut.empty?
                freeShortcut(shortcut)
                link.setAttribute('accesskey', shortcut)
              end
            end
            Hatemile::Util::CommonFunctions.generateId(link, @prefixId)

            itemLink.appendElement(link)
            @listSkippers.appendElement(itemLink)

            executeFixShortcut(link)
          end
        end
      end

      def fixSkippers
        @skippers.each do |skipper|
          elements = @parser.find(skipper.getSelector).listResults
          count = elements.size > 1
          index = 1 if count
          shortcuts = skipper.getShortcuts
          elements.each do |element|
            unless element.hasAttribute?(@dataIgnore)
              if count
                defaultText = "#{skipper.getDefaultText} #{index}"
                index = index + 1
              else
                defaultText = skipper.getDefaultText
              end
              if shortcuts.size > 0
                fixSkipper(element, Hatemile::Util::Skipper.new(skipper.getSelector, defaultText, shortcuts[shortcuts.size - 1]))
                shortcuts.delete_at(shortcuts.size - 1);
              else
                fixSkipper(element, Hatemile::Util::Skipper.new(skipper.getSelector, defaultText, ''))
              end
            end
          end
        end
      end

      def fixHeading(element)
        @validHeading = isValidHeading unless @validateHeading
        if @validHeading
          anchor = generateAnchorFor(element, @dataHeadingAnchorFor, @classHeadingAnchor)
          unless anchor.nil?
            list = nil
            level = getHeadingLevel(element)
            if level == 1
              list = generateListHeading
            else
              superItem = @parser.find("##{@idContainerHeading}").findDescendants("[#{@dataHeadingLevel}=\"#{(level - 1).to_s}\"]").lastResult
              unless superItem.nil?
                list = @parser.find(superItem).findChildren('ol').firstResult
                if list.nil?
                  list = @parser.createElement('ol')
                  superItem.appendElement(list)
                end
              end
            end
            unless list.nil?
              item = @parser.createElement('li')
              item.setAttribute(@dataHeadingLevel, level.to_s)

              link = @parser.createElement('a')
              link.setAttribute('href', "##{anchor.getAttribute('name')}")
              link.appendText(element.getTextContent)

              item.appendElement(link)
              list.appendElement(item)
            end
          end
        end
      end

      def fixHeadings
        elements = @parser.find('h1,h2,h3,h4,h5,h6').listResults
        elements.each do |element|
          fixHeading(element) unless element.hasAttribute?(@dataIgnore)
        end
      end
    end
  end
end
