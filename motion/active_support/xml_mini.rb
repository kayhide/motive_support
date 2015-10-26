require 'stringio'
require 'active_support/xml_mini/rexml'
require 'active_support/xml_mini/nsxmlparser'
require __ORIGINAL__

ActiveSupport::XmlMini.backend = 'NSXMLParser'
