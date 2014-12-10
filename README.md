AttrComparable! gem
===================
AttrComparable is autopilot for ruby's spaceship `<=>` operator!

AttrComparable brings convention over configuration to ruby's
[`Comparable`](http://www.ruby-doc.org/core/Comparable.html).
It lets you declare the variables you care about for equivalence as a
class macro, and takes the effort out of ruby comparisons.


Usage
-----
1. ##### Get the gem. Add to your gemfile: `gem 'attr_comparable'`

2. ##### Include `AttrComparable` in your class.

3. ##### Declare your equivalence measures to `attr_compare`

### Short Example
```ruby
class FullName
  include AttrComparable

  attr_accessor :first_name, :last_name
  attr_compare :class, :last_name, :first_name

  def initialize(first_name, last_name)
    @first_name, @last_name = first_name, last_name
  end

  def to_s; "#{first_name} #{last_name}"; end
end


joe1 = FullName.new("Joe", "Schmo")
joe2 = FullName.new("Joe", "Blow")
joe3 = FullName.new("Joe", "Schmo") # Same as joe1
ada  = FullName.new("Ada", "Lovelace")
pete = FullName.new("Peter", "Piper")
sam  = FullName.new("Sam", "Jackson")
alan = FullName.new("Alan", "Jackson")
mike = FullName.new("Mike", "Jackson")

# Now these operations work how you might expect!

joe1 == joe3
#=> true
joe1 != joe2
#=> true

the_lot = [joe1, joe2, joe3, ada, pete, sam, alan, mike]
the_lot.sort.map(&:to_s)
# => ["Joe Blow", "Alan Jackson", "Mike Jackson", "Sam Jackson", "Ada Lovelace", "Peter Piper", "Joe Schmo", "Joe Schmo"]
# Sorted by last_name, then first_name!
```

`attr_compare(*attributes)`
------------------------------------------------
Use `attr_compare <attribute list>`
to declare the attributes which should be compared, in their order of precedence.
Attributes may be nil.  nil attributes sort earlier than non-nil to match the SQL behavior for NULL.
You should declare `:class` as the first attribute to consider class part of equivalence.

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
  
  def to_s
    no_suffix = [first.presence, middle.presence, last.presence].compact.join(' ')
    [no_suffix, suffix.presence].compact.join(', ')
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
