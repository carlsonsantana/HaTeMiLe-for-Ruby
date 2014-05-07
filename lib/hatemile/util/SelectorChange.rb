#Copyright 2014 Carlson Santana Cruz
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
module Hatemile
	module Util
		class SelectorChange
			def initialize(selector, attribute, valueForAttribute)
				@selector = selector
				@attribute = attribute
				@valueForAttribute = valueForAttribute
			end
			def getSelector()
				return @selector
			end
			def setSelector(selector)
				@selector = selector
			end
			def getAttribute()
				return @atttribute
			end
			def setAttribute(attribute)
				@attribute = attribute
			end
			def getValueForAttribute()
				return @valueForAttribute
			end
			def setValueForAttribute(valueForAttribute)
				@valueForAttribute = valueForAttribute
			end
		end
	end
end