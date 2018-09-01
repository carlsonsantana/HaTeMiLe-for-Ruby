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

##
# The Hatemile module contains the interfaces with the acessibility solutions.
module Hatemile
  ##
  # The Hatemile::Util module contains the utilities of library.
  module Util
    ##
    # The Hatemile::Util::Css module contains the interfaces of CSS handles.
    module Css
      ##
      # The StyleSheetParser interface contains the methods for access the CSS
      # parser.
      #
      # @abstract
      class StyleSheetParser
        private_class_method :new

        ##
        # Returns the rules of parser by properties.
        #
        # @abstract
        # @param properties [Array<String>] The properties.
        # @return [Array<Hatemile::Util::Css.stylesheetrule.StyleSheetRule>] The
        #   rules.
        def get_rules(properties)
          # Interface method
        end
      end
    end
  end
end
