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

module Hatemile
  module Util
    ##
    # The SelectorChange class store the selector that be attribute change.
    class SelectorChange
      ##
      # Inicializes a new object with the values pre-defineds.
      #
      # @param selector [String] The selector.
      # @param attribute [String] The attribute.
      # @param value_for_attribute [String] The value of the attribute.
      def initialize(selector, attribute, value_for_attribute)
        @selector = selector
        @attribute = attribute
        @value_for_attribute = value_for_attribute
      end

      ##
      # Returns the selector.
      #
      # @return [String] The selector.
      def get_selector
        @selector
      end

      ##
      # Returns the attribute.
      #
      # @return [String] The attribute.
      def get_attribute
        @attribute
      end

      ##
      # Returns the value of the attribute.
      #
      # @return [String] The value of the attribute.
      def get_value_for_attribute
        @value_for_attribute
      end
    end
  end
end
