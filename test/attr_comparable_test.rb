require_relative './test_helper'
require File.expand_path('../../lib/attr_comparable',  __FILE__)

class ComparableTestOneParameter
  include AttrComparable
  attr_reader :last_name
  attr_compare :last_name

  def initialize(last_name)
    @last_name = last_name
  end
end

class ComparableTestManyParameters
  include AttrComparable
  attr_reader :last_name, :first_name
  attr_compare :last_name, :first_name

  def initialize(last_name, first_name)
    @last_name = last_name
    @first_name = first_name
  end
end


describe 'AttrComparable' do
  describe "one parameter" do
    before do
      @d1 = ComparableTestOneParameter.new('Jones')
      @d2 = ComparableTestOneParameter.new('Jones')
      @d3 = ComparableTestOneParameter.new('Kelley')
    end

    it "should define <=>" do
      assert_equal 0,  @d1 <=> @d2
      assert_equal -1, @d1 <=> @d3
      assert_equal 1,  @d3 <=> @d1
    end

    it "should define relative operators like Comparable" do
      assert @d1.is_a?(Comparable)
      assert @d1 < @d3
      assert @d3 >= @d2
      assert @d1 == @d2
      assert @d2 != @d3
    end
  end

  describe "many parameters" do
    before do
      @d1 = ComparableTestManyParameters.new('Jones', 'S')
      @d2 = ComparableTestManyParameters.new('Jones', 'T')
      @d3 = ComparableTestManyParameters.new('Jones', 'S')
      @d4 = ComparableTestManyParameters.new('Kelley', 'C')
    end

    it "should define <=>" do
      assert_equal 0,  @d1 <=> @d3
      assert_equal -1, @d1 <=> @d2
      assert_equal 1,  @d4 <=> @d1
    end

    it "should be Comparable" do
      assert @d1.is_a?(Comparable)
    end

    it "should define relative operators from Comparable" do
      assert @d1 < @d2
      assert @d2 >= @d3
      assert @d1 == @d3
      assert @d2 != @d3
    end
  end

  describe "many parameters with nil" do
    before do                                                  # sort order
      @d1 = ComparableTestManyParameters.new(nil, 'S')          # 1
      @d2 = ComparableTestManyParameters.new('Jones', nil)      # 2
      @d3 = ComparableTestManyParameters.new(nil, nil)          # 0
      @d4 = ComparableTestManyParameters.new('Jones', 'S')      # 3
    end

    it "should define <=> with nil first" do
      assert_equal 0,  @d1 <=> @d1
      assert_equal 0,  @d3 <=> @d3
      assert_equal -1, @d1 <=> @d2
      assert_equal 1,  @d2 <=> @d3
      assert_equal -1,  @d2 <=> @d4
    end

    it "should define relative operators from Comparable" do
      assert @d1 == @d1
      assert @d2 > @d3
      assert @d2 != @d3
    end
  end

  describe "parameters that are incompatible to order" do
    it "should return nil when the objects contain incompatible attributes" do
      d1 = ComparableTestOneParameter.new(false)
      d2 = ComparableTestOneParameter.new(true)
      d3 = ComparableTestManyParameters.new(false, 'D')
      d4 = ComparableTestManyParameters.new(true, 'D')
      d5 = ComparableTestManyParameters.new('Kelly', false)
      d6 = ComparableTestManyParameters.new('Kelly', true)

      assert_nil d1 <=> d2
      assert_nil d3 <=> d4
      assert_nil d5 <=> d6
    end

    # For ComparableTestManyParameters the objects are compared by last_name then first_name
    # If the comparison of last_names returns nil, that should immediately return nil,
    # and not compare the remaining attributes. This code tests that by raising a runtime error
    # if the first_name attribute (later in the compare order) is acessed

    it "should return immediately return nils, not evaulate further attributes" do
      incompatible_first_attribute = ComparableTestManyParameters.new('Kelly', false)
      compatible_first_and_second_attribute = ComparableTestManyParameters.new(true, 'D')

      d7 = Minitest::Mock.new
      d8 = Minitest::Mock.new

      2.times { d7.expect :last_name, false, [] } # :last_name is used exactly twice per <=> call
      d7.expect :nil?, false, [] # :nil? is used exactly once per <=> call
      assert_nil incompatible_first_attribute <=> d7

      2.times { d8.expect :last_name, true, [] }
      2.times { d8.expect :first_name, 'D', [] }
      d8.expect :nil?, false, []
      assert_equal 0, compatible_first_and_second_attribute <=> d8

      d7.verify
      d8.verify
    end

    it "should return nil if the rhs is nil" do
      d1 = ComparableTestOneParameter.new(false)
      d2 = ComparableTestManyParameters.new('Kelly', false)

      assert_nil d1 <=> nil
      assert_nil d2 <=> nil
    end
  end
end
