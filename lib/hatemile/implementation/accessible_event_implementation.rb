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

require File.dirname(__FILE__) + '/../accessible_event.rb'
require File.dirname(__FILE__) + '/../util/common_functions.rb'

module Hatemile
  module Implementation
    ##
    # The AccessibleEventImplementation class is official implementation of
    # AccessibleEvent interface.
    class AccessibleEventImplementation < AccessibleEvent
      public_class_method :new

      ##
      # The content of eventlistener.js.
      @@eventListenerScriptContent = nil

      ##
      # The content of include.js.
      @@includeScriptContent = nil

      protected

      ##
      # Provide keyboard access for element, if it not has.
      #
      # ---
      #
      # Parameters:
      #  1. Hatemile::Util::HTMLDOMElement +element+ The element.
      def keyboard_access(element)
        return if element.has_attribute?('tabindex')

        tag = element.get_tag_name
        if (tag == 'A') && !element.has_attribute?('href')
          element.set_attribute('tabindex', '0')
        elsif (tag != 'A') && (tag != 'INPUT') && (tag != 'BUTTON') && (tag != 'SELECT') && (tag != 'TEXTAREA')
          element.set_attribute('tabindex', '0')
        end
      end

      ##
      # Include the scripts used by solutions.
      def generate_main_scripts
        head = @parser.find('head').first_result
        if !head.nil? && @parser.find("##{@idScriptEventListener}").first_result.nil?
          if @storeScriptsContent
            if @@eventListenerScriptContent.nil?
              @@eventListenerScriptContent = File.read(File.dirname(__FILE__) + '/../../js/eventlistener.js')
            end
            localEventListenerScriptContent = @@eventListenerScriptContent
          else
            localEventListenerScriptContent = File.read(File.dirname(__FILE__) + '/../../js/eventlistener.js')
          end

          script = @parser.create_element('script')
          script.set_attribute('id', @idScriptEventListener)
          script.set_attribute('type', 'text/javascript')
          script.append_text(localEventListenerScriptContent)
          if head.has_children?
            head.get_first_element_child.insert_before(script)
          else
            head.append_element(script)
          end
        end
        local = @parser.find('body').first_result
        unless local.nil?
          @scriptList = @parser.find("##{@idListIdsScript}").first_result
          if @scriptList.nil?
            @scriptList = @parser.create_element('script')
            @scriptList.set_attribute('id', @idListIdsScript)
            @scriptList.set_attribute('type', 'text/javascript')
            @scriptList.append_text('var activeElements = [];')
            @scriptList.append_text('var hoverElements = [];')
            @scriptList.append_text('var dragElements = [];')
            @scriptList.append_text('var dropElements = [];')
            local.append_element(@scriptList)
          end
          if @parser.find("##{@idFunctionScriptFix}").first_result.nil?
            if @storeScriptsContent
              if @@includeScriptContent.nil?
                @@includeScriptContent = File.read(File.dirname(__FILE__) + '/../../js/include.js')
              end
              localIncludeScriptContent = @@includeScriptContent
            else
              localIncludeScriptContent = File.read(File.dirname(__FILE__) + '/../../js/include.js')
            end

            scriptFunction = @parser.create_element('script')
            scriptFunction.set_attribute('id', @idFunctionScriptFix)
            scriptFunction.set_attribute('type', 'text/javascript')
            scriptFunction.append_text(localIncludeScriptContent)
            local.append_element(scriptFunction)
          end
        end
        @mainScriptAdded = true
      end

      ##
      # Add a type of event in element.
      #
      # ---
      #
      # Parameters:
      #  1. Hatemile::Util::HTMLDOMElement +element+ The element.
      #  2. String +event+ The type of event.
      def add_event_in_element(element, event)
        generate_main_scripts unless @mainScriptAdded

        return if @scriptList.nil?

        Hatemile::Util::CommonFunctions.generate_id(element, @prefixId)
        @scriptList.append_text("#{event}Elements.push('#{element.get_attribute('id')}');")
      end

      public

      ##
      # Initializes a new object that manipulate the accessibility of the
      # Javascript events of elements of parser.
      #
      # ---
      #
      # Parameters:
      #  1. Hatemile::Util::HTMLDOMParser +parser+ The HTML parser.
      #  2. Hatemile::Util::Configure +configure+ The configuration of HaTeMiLe.
      #  3. Boolean +storeScriptsContent+ The state that indicates if the
      #  scripts used are stored or deleted, after use.
      def initialize(parser, configure, storeScriptsContent)
        @parser = parser
        @storeScriptsContent = storeScriptsContent
        @prefixId = configure.get_parameter('prefix-generated-ids')
        @idScriptEventListener = 'script-eventlistener'
        @idListIdsScript = 'list-ids-script'
        @idFunctionScriptFix = 'id-function-script-fix'
        @dataIgnore = 'data-ignoreaccessibilityfix'
        @mainScriptAdded = false
        @scriptList = nil
      end

      def fix_drop(element)
        element.set_attribute('aria-dropeffect', 'none')

        add_event_in_element(element, 'drop')
      end

      def fix_drag(element)
        keyboard_access(element)

        element.set_attribute('aria-grabbed', 'false')

        add_event_in_element(element, 'drag')
      end

      def fix_drags_and_drops
        draggableElements = @parser.find('[ondrag],[ondragstart],[ondragend]').list_results
        draggableElements.each do |draggableElement|
          unless draggableElement.has_attribute?(@dataIgnore)
            fix_drag(draggableElement)
          end
        end
        droppableElements = @parser.find('[ondrop],[ondragenter],[ondragleave],[ondragover]').list_results
        droppableElements.each do |droppableElement|
          unless droppableElement.has_attribute?(@dataIgnore)
            fix_drop(droppableElement)
          end
        end
      end

      def fix_hover(element)
        keyboard_access(element)

        add_event_in_element(element, 'hover')
      end

      def fix_hovers
        elements = @parser.find('[onmouseover],[onmouseout]').list_results
        elements.each do |element|
          fix_hover(element) unless element.has_attribute?(@dataIgnore)
        end
      end

      def fix_active(element)
        keyboard_access(element)

        add_event_in_element(element, 'active')
      end

      def fix_actives
        elements = @parser.find('[onclick],[onmousedown],[onmouseup],[ondblclick]').list_results
        elements.each do |element|
          fix_active(element) unless element.has_attribute?(@dataIgnore)
        end
      end
    end
  end
end
