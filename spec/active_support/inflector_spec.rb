module InflectorHelper
  # Dups the singleton and yields, restoring the original inflections later.
  # Use this in tests what modify the state of the singleton.
  #
  # This helper is implemented by setting @__instance__ because in some tests
  # there are module functions that access ActiveSupport::Inflector.inflections,
  # so we need to replace the singleton itself.
  def with_dup
    instance = ActiveSupport::Inflector::Inflections.instance_variable_get(:@__instance__)
    original = instance[:en]
    instance[:en] = original.dup
    yield
  ensure
    instance = ActiveSupport::Inflector::Inflections.instance_variable_get(:@__instance__)
    instance[:en] = original
  end
end

describe "Inflector" do
  describe "singularize/pluralize" do
    extend InflectorHelper
    
    it "should pluralize plurals" do
      ActiveSupport::Inflector.pluralize("plurals").should == "plurals"
      ActiveSupport::Inflector.pluralize("Plurals").should == "Plurals"
    end
  
    it "should pluralize empty string" do
      ActiveSupport::Inflector.pluralize("").should == ""
    end
  
    ActiveSupport::Inflector.inflections.uncountable.each do |word|
      it "should treat #{word} as uncountable" do
        ActiveSupport::Inflector.singularize(word).should == word
        ActiveSupport::Inflector.pluralize(word).should == word
        ActiveSupport::Inflector.singularize(word).should == ActiveSupport::Inflector.pluralize(word)
      end
    end
  
    InflectorTestCases::SingularToPlural.each do |singular, plural|
      it "should pluralize singular #{singular}" do
        ActiveSupport::Inflector.pluralize(singular).should == plural
        ActiveSupport::Inflector.pluralize(singular.capitalize).should == plural.capitalize
      end

      it "should singularize plural #{plural}" do
        ActiveSupport::Inflector.singularize(plural).should == singular
        ActiveSupport::Inflector.singularize(plural.capitalize).should == singular.capitalize
      end

      it "should pluralize plural #{plural}" do
        ActiveSupport::Inflector.pluralize(plural).should == plural
        ActiveSupport::Inflector.pluralize(plural.capitalize).should == plural.capitalize
      end

      it "should singularize singular #{singular}" do
        ActiveSupport::Inflector.singularize(singular).should == singular
        ActiveSupport::Inflector.singularize(singular.capitalize).should == singular.capitalize
      end
    end
    
    it "should handle uncountable words non-greedily" do
      with_dup do
        uncountable_word = "ors"
        countable_word = "sponsor"

        ActiveSupport::Inflector.inflections.uncountable << uncountable_word

        ActiveSupport::Inflector.singularize(uncountable_word).should == uncountable_word
        ActiveSupport::Inflector.pluralize(uncountable_word).should == uncountable_word
        ActiveSupport::Inflector.pluralize(uncountable_word).should == ActiveSupport::Inflector.singularize(uncountable_word)

        ActiveSupport::Inflector.singularize(countable_word).should == "sponsor"
        ActiveSupport::Inflector.pluralize(countable_word).should == "sponsors"
        ActiveSupport::Inflector.singularize(ActiveSupport::Inflector.pluralize(countable_word)).should == "sponsor"
      end
    end
  end
  
  describe "titleize" do
    InflectorTestCases::MixtureToTitleCase.each do |before, titleized|
      it "should titleize #{before}" do
        ActiveSupport::Inflector.titleize(before).should == titleized
      end
    end
  end
  
  describe "underscore" do
    InflectorTestCases::CamelToUnderscore.each do |camel, underscore|
      it "should underscore #{camel}" do
        ActiveSupport::Inflector.underscore(camel).should == underscore
      end
    end
  
    InflectorTestCases::CamelToUnderscoreWithoutReverse.each do |camel, underscore|
      it "should underscore #{camel}" do
        ActiveSupport::Inflector.underscore(camel).should == underscore
      end
    end

    InflectorTestCases::CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      it "should underscore #{camel}" do
        ActiveSupport::Inflector.underscore(camel).should == underscore
      end
    end
  end
  
  describe "camelize" do
    InflectorTestCases::CamelToUnderscore.each do |camel, underscore|
      it "should camelize #{underscore}" do
        ActiveSupport::Inflector.camelize(underscore).should == camel
      end
    end

    InflectorTestCases::CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      it "should camelize #{underscore}" do
        ActiveSupport::Inflector.camelize(underscore).should == camel
      end
    end
  
    it "should downcase first letter if called with lower" do
      ActiveSupport::Inflector.camelize('Capital', false).should == 'capital'
    end

    it "should remove underscores" do
      ActiveSupport::Inflector.camelize('Camel_Case').should == "CamelCase"
    end
    
    InflectorTestCases::UnderscoreToLowerCamel.each do |underscored, lower_camel|
      it "should lower-camelize #{underscored}" do
        ActiveSupport::Inflector.camelize(underscored, false).should == lower_camel
      end
    end

    InflectorTestCases::SymbolToLowerCamel.each do |symbol, lower_camel|
      it "should lower-camelize symbol :#{symbol}" do
        ActiveSupport::Inflector.camelize(symbol, false).should == lower_camel
      end
    end
  end
  
  describe "irregularities" do
    InflectorTestCases::Irregularities.each do |irregularity|
      singular, plural = *irregularity
      ActiveSupport::Inflector.inflections do |inflect|
        it "should singularize #{plural} as #{singular}" do
          inflect.irregular(singular, plural)
          ActiveSupport::Inflector.singularize(plural).should == singular
        end
        
        it "should pluralize #{singular} as #{plural}" do
          inflect.irregular(singular, plural)
          ActiveSupport::Inflector.pluralize(singular).should == plural
        end
      end

      ActiveSupport::Inflector.inflections do |inflect|
        it "should return same string when pluralizing irregular plural #{plural}" do
          inflect.irregular(singular, plural)
          ActiveSupport::Inflector.pluralize(plural).should == plural
        end
      end

      ActiveSupport::Inflector.inflections do |inflect|
        it "should return same string when singularizing irregular singular #{singular}" do
          inflect.irregular(singular, plural)
          ActiveSupport::Inflector.singularize(singular).should == singular
        end
      end
    end
  end
  
  it "should overwrite previous inflectors" do
    ActiveSupport::Inflector.singularize("series").should == "series"
    ActiveSupport::Inflector.inflections.singular "series", "serie"
    ActiveSupport::Inflector.singularize("series").should == "serie"
    ActiveSupport::Inflector.inflections.uncountable "series" # Return to normal
  end
  
  describe "acronym" do
    before do
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.acronym("API")
        inflect.acronym("HTML")
        inflect.acronym("HTTP")
        inflect.acronym("RESTful")
        inflect.acronym("W3C")
        inflect.acronym("PhD")
        inflect.acronym("RoR")
        inflect.acronym("SSL")
      end
    end

    #  camelize             underscore            humanize              titleize
    [
      ["API",               "api",                "API",                "API"],
      ["APIController",     "api_controller",     "API controller",     "API Controller"],
      ["Nokogiri::HTML",    "nokogiri/html",      "Nokogiri/HTML",      "Nokogiri/HTML"],
      ["HTTPAPI",           "http_api",           "HTTP API",           "HTTP API"],
      ["HTTP::Get",         "http/get",           "HTTP/get",           "HTTP/Get"],
      ["SSLError",          "ssl_error",          "SSL error",          "SSL Error"],
      ["RESTful",           "restful",            "RESTful",            "RESTful"],
      ["RESTfulController", "restful_controller", "RESTful controller", "RESTful Controller"],
      ["IHeartW3C",         "i_heart_w3c",        "I heart W3C",        "I Heart W3C"],
      ["PhDRequired",       "phd_required",       "PhD required",       "PhD Required"],
      ["IRoRU",             "i_ror_u",            "I RoR u",            "I RoR U"],
      ["RESTfulHTTPAPI",    "restful_http_api",   "RESTful HTTP API",   "RESTful HTTP API"],
      ["UIImage",           "ui_image",           "UI image",           "UI Image"],

      # misdirection
      ["Capistrano",        "capistrano",         "Capistrano",       "Capistrano"],
      ["CapiController",    "capi_controller",    "Capi controller",  "Capi Controller"],
      ["HttpsApis",         "https_apis",         "Https apis",       "Https Apis"],
      ["Html5",             "html5",              "Html5",            "Html5"],
      ["Restfully",         "restfully",          "Restfully",        "Restfully"],
      ["RoRails",           "ro_rails",           "Ro rails",         "Ro Rails"]
    ].each do |camel, under, human, title|
      it "should camelize #{under} as #{camel}" do
        ActiveSupport::Inflector.camelize(under).should == camel
      end
      
      it "should keep #{camel} camelized" do
        ActiveSupport::Inflector.camelize(camel).should == camel
      end
      
      it "should keep #{under} underscored" do
        ActiveSupport::Inflector.underscore(under).should == under
      end
      
      it "should underscore #{camel} as #{under}" do
        ActiveSupport::Inflector.underscore(camel).should == under
      end
      
      it "should titleize #{under} as #{title}" do
        ActiveSupport::Inflector.titleize(under).should == title
      end
      
      it "should titleize #{camel} as #{title}" do
        ActiveSupport::Inflector.titleize(camel).should == title
      end
      
      it "should humanize #{under} as #{human}" do
        ActiveSupport::Inflector.humanize(under).should == human
      end
    end

    describe "override acronyms" do
      before do
        ActiveSupport::Inflector.inflections do |inflect|
          inflect.acronym("API")
          inflect.acronym("LegacyApi")
        end
      end

      {
        "legacyapi" => "LegacyApi",
        "legacy_api" => "LegacyAPI",
        "some_legacyapi" => "SomeLegacyApi",
        "nonlegacyapi" => "Nonlegacyapi"
      }.each do |from, to|
        it "should camelize #{from} as #{to}" do
          ActiveSupport::Inflector.camelize(from).should == to
        end
      end
    end

    describe "lower-camelize with acronym parts" do
      before do
        ActiveSupport::Inflector.inflections do |inflect|
          inflect.acronym("API")
          inflect.acronym("HTML")
        end
      end
      
      {
        "html_api" => "htmlAPI",
        "htmlAPI" => "htmlAPI",
        "HTMLAPI" => "htmlAPI"
      }.each do |from, to|
        it "should lower-camelize #{from} as #{to}" do
          ActiveSupport::Inflector.camelize(from, false).should == to
        end
      end
    end

    it "should underscore acronym sequence" do
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.acronym("API")
        inflect.acronym("JSON")
        inflect.acronym("HTML")
      end

      ActiveSupport::Inflector.underscore("JSONHTMLAPI").should == "json_html_api"
    end
  end
  
  describe "demodulize" do
    {
      "MyApplication::Billing::Account" => "Account",
      "Account" => "Account",
      "" => ""
    }.each do |from, to|
      it "should transform #{from} to #{to}" do
        ActiveSupport::Inflector.demodulize(from).should == to
      end
    end
  end

  describe "deconstantize" do
    {
      "MyApplication::Billing::Account" => "MyApplication::Billing",
      "::MyApplication::Billing::Account" => "::MyApplication::Billing",
      "MyApplication::Billing" => "MyApplication",
      "::MyApplication::Billing" => "::MyApplication",
      "Account" => "",
      "::Account" => "",
      "" => ""
    }.each do |from, to|
      it "should deconstantize #{from} as #{to}" do
        ActiveSupport::Inflector.deconstantize(from).should == to
      end
    end
  end
  
  describe "foreign_key" do
    InflectorTestCases::ClassNameToForeignKeyWithUnderscore.each do |klass, foreign_key|
      it "should create foreign key for class name #{klass}" do
        ActiveSupport::Inflector.foreign_key(klass).should == foreign_key
      end
    end

    InflectorTestCases::ClassNameToForeignKeyWithoutUnderscore.each do |klass, foreign_key|
      it "should create foreign key for class name #{klass} without underscore" do
        ActiveSupport::Inflector.foreign_key(klass, false).should == foreign_key
      end
    end
  end
  
  describe "tableize" do
    InflectorTestCases::ClassNameToTableName.each do |class_name, table_name|
      it "should create table name from class name #{class_name}" do
        ActiveSupport::Inflector.tableize(class_name).should == table_name
      end
    end
  end

  describe "classify" do
    InflectorTestCases::ClassNameToTableName.each do |class_name, table_name|
      it "should classify #{table_name}" do
        ActiveSupport::Inflector.classify(table_name).should == class_name
      end
      
      it "should classify #{table_name} with table prefix" do
        ActiveSupport::Inflector.classify("table_prefix." + table_name).should == class_name
      end
    end

    it "should classify with symbol" do
      lambda do
        ActiveSupport::Inflector.classify(:foo_bars).should == 'FooBar'
      end.should.not.raise
    end

    it "should classify with leading schema name" do
      ActiveSupport::Inflector.classify('schema.foo_bar').should == 'FooBar'
    end
  end
  
  describe "humanize" do
    InflectorTestCases::UnderscoreToHuman.each do |underscore, human|
      it "should humanize #{underscore}" do
        ActiveSupport::Inflector.humanize(underscore).should == human
      end
    end

    it "should humanize by rule" do
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.human(/_cnt$/i, '\1_count')
        inflect.human(/^prefx_/i, '\1')
      end
      ActiveSupport::Inflector.humanize("jargon_cnt").should == "Jargon count"
      ActiveSupport::Inflector.humanize("prefx_request").should == "Request"
    end

    it "should humanize by string" do
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.human("col_rpted_bugs", "Reported bugs")
      end
      ActiveSupport::Inflector.humanize("col_rpted_bugs").should == "Reported bugs"
      ActiveSupport::Inflector.humanize("COL_rpted_bugs").should == "Col rpted bugs"
    end
  end
  
  describe "constantize" do
    extend ConstantizeTestCases
    
    it "should constantize" do
      run_constantize_tests_on do |string|
        ActiveSupport::Inflector.constantize(string)
      end
    end
  end
  
  describe "safe_constantize" do
    extend ConstantizeTestCases
    
    it "should safe_constantize" do
      run_safe_constantize_tests_on do |string|
        ActiveSupport::Inflector.safe_constantize(string)
      end
    end
  end
  
  describe "ordinal" do
    InflectorTestCases::OrdinalNumbers.each do |number, ordinalized|
      it "should return ordinal of number #{number}" do
        (number + ActiveSupport::Inflector.ordinal(number)).should == ordinalized
      end
    end
  end
  
  describe "ordinalize" do
    InflectorTestCases::OrdinalNumbers.each do |number, ordinalized|
      it "should ordinalize number #{number}" do
        ActiveSupport::Inflector.ordinalize(number).should == ordinalized
      end
    end
  end
  
  describe "dasherize" do
    InflectorTestCases::UnderscoresToDashes.each do |underscored, dasherized|
      it "should dasherize #{underscored}" do
        ActiveSupport::Inflector.dasherize(underscored).should == dasherized
      end
    end

    InflectorTestCases::UnderscoresToDashes.each_key do |underscored|
      it "should dasherize and then underscore #{underscored}, returning #{underscored}" do
        ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.dasherize(underscored)).should == underscored
      end
    end
  end
  
  describe "clear" do
    extend InflectorHelper
    
    %w{plurals singulars uncountables humans acronyms}.each do |inflection_type|
      it "should clear #{inflection_type}" do
        with_dup do
          ActiveSupport::Inflector.inflections.clear inflection_type.to_sym
          ActiveSupport::Inflector.inflections.send(inflection_type).should.be.empty
        end
      end
    end

    it "should clear all" do
      with_dup do
        ActiveSupport::Inflector.inflections do |inflect|
          # ensure any data is present
          inflect.plural(/(quiz)$/i, '\1zes')
          inflect.singular(/(database)s$/i, '\1')
          inflect.uncountable('series')
          inflect.human("col_rpted_bugs", "Reported bugs")
    
          inflect.clear :all
    
          inflect.plurals.should.be.empty
          inflect.singulars.should.be.empty
          inflect.uncountables.should.be.empty
          inflect.humans.should.be.empty
        end
      end
    end
    
    it "should clear with default" do
      with_dup do
        ActiveSupport::Inflector.inflections do |inflect|
          # ensure any data is present
          inflect.plural(/(quiz)$/i, '\1zes')
          inflect.singular(/(database)s$/i, '\1')
          inflect.uncountable('series')
          inflect.human("col_rpted_bugs", "Reported bugs")
    
          inflect.clear
    
          inflect.plurals.should.be.empty
          inflect.singulars.should.be.empty
          inflect.uncountables.should.be.empty
          inflect.humans.should.be.empty
        end
      end
    end
    
    %w(plurals singulars uncountables humans acronyms).each do |scope|
      it "should clear inflections with #{scope}" do
        with_dup do
          ActiveSupport::Inflector.inflections do |inflect|
            # clear the inflections
            inflect.clear(scope)
            inflect.send(scope).should == []
          end
        end
      end
    end
  end
end
