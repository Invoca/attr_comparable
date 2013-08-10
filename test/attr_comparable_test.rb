require File.expand_path('../../lib/attr_comparable',  __FILE__)
require 'bundler'
Bundler.require(:default)
require 'minitest/autorun'


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

  it "should be able to compare with nil" do
    assert_equal nil, ComparableTestManyParameters.compare_with_nil(nil, nil)
    assert_equal -1, ComparableTestManyParameters.compare_with_nil(nil, 1)
    assert_equal  1, ComparableTestOneParameter.compare_with_nil(1, nil)
    assert_equal  1, ComparableTestOneParameter.compare_with_nil("dog", "cat")
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
end
