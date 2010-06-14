
require File.dirname(__FILE__) + '/test_helper'

class SoundexFindTest < Test::Unit::TestCase

  context "A soundex model with default SoundexFind options" do

    setup do
      Item.delete_all
      Item.soundex_columns(:name)
      
      NAMES.keys.each do |name|
        Item.create! :name => name
      end
    end

    should "have a soundex value" do
      assert_not_nil Item.find(:first).name_soundex
    end

    should "find all records" do
      items = Item.find(:all)
      assert_equal(NAMES.size, items.size, "with find :all")
    end
    
    should "have soundex length" do
      assert_equal(1, Item.find_by_name("sue").name_soundex.length, "equals 1")
      assert_equal(2, Item.find_by_name("soup").name_soundex.length, "equals 2")
      assert_equal(3, Item.find_by_name("super").name_soundex.length, "equals 3")
      assert_equal(7, Item.find_by_name("supernatural").name_soundex.length, "equals 7")
    end
    
    should "find records when using " do
      items = Item.soundex_find(:all, :soundex => "")
      assert_equal(11, items.size, "blank soundex string")

      items = Item.soundex_find(:all, :soundex => "zoo")
      assert_equal(11, items.size, "different first letter")

      items = Item.soundex_find(:all, :soundex => "per")
      assert_equal(4, items.size, "internal substring")

      items = Item.soundex_find(:all, :soundex => "su")
      assert_equal(11, items.size, "short string")

      items = Item.soundex_find(:all, :soundex => "sheuvir")
      assert_equal(4, items.size, "phonetic string")
    end
    
    should "not find records when using " do
      items = Item.soundex_find(:all, :soundex => "supernaturalsupernatural")
      assert_equal(0, items.size, "long soundex string")
    end
    
  end

  context "A soundex model with strict SoundexFind options" do
  
    setup do
      Item.delete_all
      Item.soundex_columns(:name, {:start => true, :end => true, :limit => 3, :strict => true})
      
      NAMES.keys.each do |name|
        Item.create! :name => name
      end
    end
  
    should "have a soundex value" do
      assert_not_nil Item.find(:first).name_soundex
    end
  
    should "find all records" do
      items = Item.find(:all)
      assert_equal(NAMES.size, items.size, "with find :all")
    end
    
    should "have soundex length" do
      if Item.sdx_options[:limit]
        Item.find(:all).each do |item|
          assert_equal(Item.sdx_options[:limit].to_i + 1, item.name_soundex.length, "equal to limit + 1 if limit set")
        end
      end
    end
    
    should "have a specific soundex value" do
      NAMES.each do |name, value|
        assert_equal(value, Item.find_by_name(name).name_soundex, name)
      end
    end
    
    should "find records when using " do
      items = Item.soundex_find(:all, :soundex => "supernaturalsupernatural")
      assert_equal(1, items.size, "long soundex string #{Item.soundex("supernaturalsupernatural")}")
      
      items = Item.soundex_find(:all, :soundex => "su")
      assert_equal(1, items.size, "short string")
      
      items = Item.soundex_find(:all, :soundex => "sheuvir")
      assert_equal(3, items.size, "phonetic string")
    end
    
    should "not find records when using " do
      
      items = Item.soundex_find(:all, :soundex => "")
      assert_equal(0, items.size, "blank soundex string")
      
      items = Item.soundex_find(:all, :soundex => "zoo")
      assert_equal(0, items.size, "different first letter")
      
      items = Item.soundex_find(:all, :soundex => "per")
      assert_equal(0, items.size, "internal substring")
    end
   
  end
  
  context "A soundex model with auto-complete SoundexFind options" do
  
    setup do
      Item.delete_all
      Item.soundex_columns(:name, {:start => true, :strict => true})
      
      NAMES.keys.each do |name|
        Item.create! :name => name
      end
    end
  
    should "have a soundex value" do
      assert_not_nil Item.find(:first).name_soundex
    end
  
    should "find all records" do
      items = Item.find(:all)
      assert_equal(NAMES.size, items.size, "with find :all")
    end
    
    should "have soundex length" do
      assert_equal(1, Item.find_by_name("sue").name_soundex.length, "equals 1")
      assert_equal(2, Item.find_by_name("soup").name_soundex.length, "equals 2")
      assert_equal(3, Item.find_by_name("super").name_soundex.length, "equals 3")
      assert_equal(7, Item.find_by_name("supernatural").name_soundex.length, "equals 7")
    end
    
    should "find records when using " do
      items = Item.soundex_find(:all, :soundex => "")
      assert_equal(NAMES.size, items.size, "blank soundex string")
  
      items = Item.soundex_find(:all, :soundex => "su")
      assert_equal(6, items.size, "short string")
  
      items = Item.soundex_find(:all, :soundex => "sheuvir")
      assert_equal(4, items.size, "phonetic string")
    end
    
    should "not find records when using " do  
      items = Item.soundex_find(:all, :soundex => "supernaturalsupernatural")
      assert_equal(0, items.size, "long soundex string")
      
      items = Item.soundex_find(:all, :soundex => "zoo")
      assert_equal(0, items.size, "different first letter")
  
      items = Item.soundex_find(:all, :soundex => "per")
      assert_equal(0, items.size, "internal substring")
    end
    
  end
  
end