require __ORIGINAL__

module Builder
  module XChar

    # Overwrite original
    # String#encode does not work
    def XChar.unicode(string)
      string
    end

    # Overwrite original
    # cp1252 cleaning does not work
    def XChar.encode(string)
      unicode(string).
        # tr(CP1252_DIFFERENCES, UNICODE_EQUIVALENT).
        gsub(INVALID_XML_CHAR, REPLACEMENT_CHAR).
        gsub(XML_PREDEFINED) {|c| PREDEFINED[c.ord]}
    end
  end
end
