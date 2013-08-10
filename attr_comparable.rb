#
# Mix-in to make a class Comparable
#
# Use attr_comparabie <attribute list>
# to declare the attributes which should be compared, and the order they should be
# Attributes may be nil; nil attributes sort earlier than non-nil to match the SQL convention
#
module AttrComparable
  include Comparable

  module ClassMethods
    # like <=> but handles nil values
    # when equal, returns nil rather than 0 so the caller can || together
    def compare_with_nil(left, right)
      if left.nil?
        if right.nil?
          nil
        else
          -1
        end
      elsif right.nil?
        1
      else
        (left <=> right).nonzero?
      end
    end

    def attr_compare(*attributes)
      attributes = attributes.flatten
      class_eval <<-EOS
        def <=>(rhs)
          #{attributes.map do |attribute|
              "self.class.compare_with_nil(self.#{attribute}, rhs.#{attribute})"
            end.join(" || ")
           } || 0
        end
      EOS
    end
  end

  def self.included(base_class)
    base_class.extend ClassMethods
  end
end
