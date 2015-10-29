require __ORIGINAL__

module Builder
  class XmlBase < BlankSlate

    # Overwrite original
    # String#encode does not work
    def _escape(text)
      text
    end
  end
end
