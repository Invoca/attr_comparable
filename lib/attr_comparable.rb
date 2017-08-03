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
    def compare_with_nil_code(left, right)
      <<-EOS
        if #{ left }.nil?
          if #{ right }.nil?
            0
          else
            -1
          end
        elsif #{ right }.nil?
          1
        else
          cmp_result = (#{ left } <=> #{ right })
          return nil if cmp_result.nil?
          cmp_result
        end
      EOS
    end

    def attr_compare(*attributes)
      attr_exprs = (attributes.flatten).map do |attribute|
        '(' + compare_with_nil_code("self.#{attribute}", "rhs.#{attribute}").strip + ')'
      end

      class_eval <<-EOS
        def <=>(rhs)
          #{ attr_exprs.join(".nonzero? || ") }
        end
      EOS
    end
  end

  def self.included(base_class)
    base_class.extend ClassMethods
  end
end
