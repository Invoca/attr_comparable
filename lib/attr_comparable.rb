#
# Mix-in to make a class Comparable
#
# Use attr_comparabie <attribute list>
# to declare the attributes which should be compared, and the order they should be
# Attributes may be nil; nil attributes sort earlier than non-nil to match SQL NULL ordering
#
module AttrComparable
  include Comparable

  module ClassMethods
    # like <=> but handles nil values
    # returns the code in string form to be eval'd
    # code will return nil instead of 0 for equal iff return_nil_on_equal is truthy
    def compare_with_nil_code(left, right, return_nil_on_equal)
      <<-EOS
        if #{ left }.nil?
          if #{ right }.nil?
            #{ return_nil_on_equal ? 'nil' : '0' }
          else
            -1
          end
        elsif #{ right }.nil?
          1
        else
          (#{ left } <=> #{ right })#{ '.nonzero?' if return_nil_on_equal }
        end
      EOS
    end

    def attr_compare(*attributes_arg)
      attributes = attributes_arg.flatten

      remaining_attrs = attributes.size;
      attr_exprs = attributes.map do |attribute|
        remaining_attrs -= 1
        compare_with_nil_code("self.#{attribute}", "rhs.#{attribute}", remaining_attrs.nonzero?).strip
      end

      class_eval <<-EOS
        def <=>(rhs)
          #{ attr_exprs.join(" || ") }
        end
      EOS
    end
  end

  def self.included(base_class)
    base_class.extend ClassMethods
  end
end
