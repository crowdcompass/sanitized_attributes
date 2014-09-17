require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SanitizedAttributes" do

  before do
    @klass = Class.new do
      include SanitizedAttributes
      attr_accessor :orz
      attr_accessor :vux
    end
    SanitizedAttributes.add_option(:no_empties) do |env, forbidden_empties|
      if env[:node].content.empty?
        if forbidden_empties.include?(env[:node_name])
          env[:node].unlink
        end
      end
    end
    SanitizedAttributes.add_option(:gsub) do |env, substitutions|
      env[:node].children.each do |node|
        if node.kind_of?(Nokogiri::XML::Text)
          text = node.content
          substitutions.each do |regex, subst|
            text.gsub!(regex, subst)
          end
          node.content = text
        end
      end
      nil
    end
    SanitizedAttributes.add_profile(:default, :gsub => { "\r" => "" })
    SanitizedAttributes.add_profile(:default, :gsub => { "**" => "_" })
    SanitizedAttributes.add_profile(:quotes_only, :elements => %w[blockquote])
  end

  it "removes all HTML by default" do
    @klass.module_eval do
      sanitize_attribute :orz
    end
    obj = @klass.new
    obj.orz = "<a>Orz are not *many bubbles* like <p/>*campers*. <p></p>Orz <b>are just</b> Orz. <p>- Orz</p>"
    obj.orz.should == "Orz are not *many bubbles* like *campers*. Orz are just Orz. - Orz"
  end

  it "allows a default sanitizing profile to be set up" do
    SanitizedAttributes.add_profile(:default, Sanitize::Config::BASIC)
    @klass.module_eval do
      sanitize_attribute :orz
    end
    obj = @klass.new
    obj.orz = "<a>Orz are not *many bubbles* like <p/>*campers*. <p></p>Orz <b>are just</b> Orz. <p>- Orz</p>"
    obj.orz.should == "<a rel=\"nofollow\">Orz are not *many bubbles* like <p>*campers*. </p><p></p>Orz <b>are just</b> Orz. <p>- Orz</p></a>"
    SanitizedAttributes.add_profile(:default, Sanitize::Config.merge(Sanitize::Config::BASIC, :no_empties => %w[p]))
    obj.orz = "<a>Orz are not *many bubbles* like <p/>*campers*. <p></p>Orz <b>are just</b> Orz. <p>- Orz</p>"
    obj.orz.should == "<a rel=\"nofollow\">Orz are not *many bubbles* like <p>*campers*. </p>Orz <b>are just</b> Orz. <p>- Orz</p></a>"
  end

  it "sanitizes attributes with custom options and profiles" do
    @klass.module_eval do
      sanitize_attribute :orz, :elements => %w[p], :no_empties => %w[p]
      sanitize_attribute :vux, :quotes_only
    end
    obj = @klass.new
    obj.vux = "<blockquote>Our special today is <b>particle fragmentation!</b></blockquote> - VUX"
    obj.vux.should == "<blockquote>Our special today is particle fragmentation!</blockquote> - VUX"
    obj.orz = "Orz are not *many bubbles* like **campers**. <p></p>Orz <b>are just</b> Orz. <p>- Orz</p>"
    obj.orz.should == "Orz are not *many bubbles* like _campers_. Orz are just Orz. <p>- Orz</p>"
  end
end
