attr_comparable gem
===================

Mix-in to make a class Comparable, declaratively
------------------------------------------------

Use `attr_compare <attribute list>`
to declare the attributes which should be compared, in their order of precedence.
Attributes may be nil.  nil attributes sort earlier than non-nil to match the SQL behavior for NULL.

Example without AttrComparable
------------------------------

Consider this value class that holds full names:
```ruby
class FullName
  include Comparable
  
  attr_reader :first, :middle, :last, :suffix
  
  def initialize(first, middle, last, suffix = nil)
    @first  = first
    @middle = middle
    @last   = last
    @suffix = suffix
  end
  
  def <=>(other)
    (last <=> other.last).nonzero? ||
      (first <=> other.first).nonzero? ||
        (middle <=> other.middle).nonzero? ||
          suffix <=> other.suffix
  end
end
```
You can see that the `<=>` method isn't very DRY, and as shown it doesn't even work with `nil`.
(That's just too ugly to show.)

Example with AttrComparable
---------------------------
Here it is using the gem.  Only the 2 lines with the comments are needed.
```ruby
require 'attr_comparable'
require 'active_support'

class FullName
  include AttrComparable                        # AttrComparable automatically includes Comparable

  attr_compare :last, :first, :middle, :suffix  # will be compared in this precedence order
  attr_reader  :first, :middle, :last, :suffix

  def initialize(first, middle, last, suffix = nil)
    @first  = first
    @middle = middle
    @last   = last
    @suffix = suffix
  end

  def to_s
    no_suffix = [first.presence, middle.presence, last.presence].compact.join(' ')
    [no_suffix, suffix.presence].compact.join(', ')
  end
end
```
Example Usage
---------------------------
```ruby
>> mom    = FullName.new("Kathy", nil, "Doe")
>> dad    = FullName.new("John", "Q.", "Public")
>> junior = FullName.new("John", "Q.", "Public", "Jr.")
>> junior > dad
=> true
>> [mom, dad, junior].sort.map &:to_s
=> ["Kathy Doe", "John Q. Public", "John Q. Public, Jr."]
```
