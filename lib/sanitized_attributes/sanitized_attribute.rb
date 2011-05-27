module SanitizedAttributes; class SanitizedAttribute

  def initialize(attr_name, options = {})
    @attr_name = attr_name
    @options = options
  end

  def sanitize(content)
    Sanitize.clean("<SPURIOUS-TOPLEVEL>" + content + "</SPURIOUS-TOPLEVEL>", sanitize_config).gsub(%r{</?SPURIOUS-TOPLEVEL>}, "")
  end

  def define_ar_writer_method(klass)
    this = self
    attr_name = @attr_name
    if klass.instance_methods.include?("#{attr_name}=")
      klass.send(:define_method, "#{attr_name}_with_sanitization=") {|value|
        send(:"#{attr_name}_without_sanitization=", this.sanitize(value))
      }
      klass.send(:alias_method_chain, :"#{attr_name}=", :sanitization)
    else
      klass.send(:define_method, "#{attr_name}=") {|value|
        send(:write_attribute, attr_name, this.sanitize(value))
      }
    end
  end

  def define_writer_method(klass)
    this = self
    attr_name = @attr_name
    klass.send(:define_method, "#{@attr_name}_with_sanitization=") {|value|
      send("#{attr_name}_without_sanitization=", this.sanitize(value))
    }
  end

  protected

    def sanitize_config
      SanitizedAttributes.sanitize_options(@options)
    end

  class << self

    def add(klass, attr_name, options = {})
      attrib = new(attr_name, options)
      if klass.respond_to?(:alias_method_chain) 
        attrib.define_ar_writer_method(klass) 
      else
        attrib.define_writer_method(klass)
        klass.send(:alias_method, "#{attr_name}_without_sanitization=", "#{attr_name}=")
        klass.send(:alias_method, "#{attr_name}=", "#{attr_name}_with_sanitization=")
      end
    end

  end
end; end
