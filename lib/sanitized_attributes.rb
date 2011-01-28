require 'rubygems'
require 'sanitize'
require 'sanitized_attributes/sanitized_attribute'

module SanitizedAttributes

  def self.included(into)
    into.extend(ClassMethods)
  end

  class << self
    
    def add_option(name, &blk)
      @option_transforms = nil
      @options ||= {}
      @options[name] = blk
    end

    def add_profile(name, options = {})
      @profiles ||= {}
      @profiles[name] = options
    end

    def profile(name)
      @profiles ||= {}
      @profiles[name] || {}
    end

    def sanitize_options(options)
      pr = 
        if options.kind_of?(Symbol)
          profile(options)
        else
          options
        end
      o = merge_options(default_profile, pr)
      o 
    end

    protected

      def default_profile
        merge_options(profile(:default), obligatory_options)
      end

      def merge_options(ops, new_ops)
        final_ops = ops.dup
        new_ops.each do |key,val|
          old = final_ops[key]
          if key == :transformers
            final_ops[key] ||= []
            final_ops[key] = ([old] + [val]).flatten.uniq.compact
          else
            final_ops[key] = val
          end
          final_ops.delete(key) if final_ops[key].nil?
        end
        return final_ops
      end

      def obligatory_options
        { :transformers => option_transforms }
      end

      def option_transforms
        @option_transforms ||= 
          begin
            if @options
              @options.map do |name, tproc|
                lambda do |env|
                  tproc.call(env, env[:config][name]) if env[:config][name]
                end
              end
            else
              []
            end
          end
      end
  end


  module ClassMethods

    def sanitize_attribute(attr_name, options = {})
      SanitizedAttribute.add(self, attr_name, options)
    end

  end

end
