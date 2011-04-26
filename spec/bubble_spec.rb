require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Bubble' do
  context 'while entagging data' do
    it 'entags a tag array' do
      data = [[:a]]
      data.to_html.should == '<a />'
    end

    it 'entags multiple arrays' do
      data = [[[:a], [:b]]]
      data.to_html.should == '<a /><b />'
    end

    it 'entags nested tag arrays' do
      data = [[:a, [:b]]]
      data.to_html.should == '<a><b /></a>'
    end

    it 'entags nested multiple tag arrays' do
      data = [[[:a, [:b]], [:c, [:d]]]]
      data.to_html.should == '<a><b /></a><c><d /></c>'
    end

    it 'entags nested arrays to an arbitrary depth' do
      data = [[:a, [:b, [:c, [:d]]]]]
      data.to_html.should == '<a><b><c><d /></c></b></a>'
    end

    it 'entags nested arrays including static text' do
      pending
      # hmmm, what should be the preferred usage...
      # [:p, 'Test', [:a, {:href => '/wut'}, 'this'], 'baby'] 
      # or
      # [:p, 'Test #{[:a, {:href => '/wut'}, 'this'].to_html} baby'] 
      data = [[:a, [:b, 'NO WAI', [:c, [:d, 'LOLWUT']]]]]
      # data.to_html.should == '<a><b>NO WAI<c><d>LOLWUT</d></c></b></a>'
    end

    it 'ignores empty nesting' do
      data = [[:a, [[[:b]]], [:c]]]
      data.to_html.should == '<a><b /><c /></a>'
    end

    it 'raises an error if a tag is not correctly wrapped' do
      data = [[:a], :c]
      lambda { data.to_html }.should raise_error(':c is not a valid tag array.  Did you mean [:c]?')
    end

    it 'renders static text' do
      data = [:p, 'this thing']
      data.to_html.should == '<p>this thing</p>'
    end

    context 'with properties' do
      it 'entags a tag array' do
        data = [[:a, {:foo => :bar}]]
        data.to_html.should == '<a foo="bar" />'
      end

      it 'renders static text' do
        data = [:p, {:class => 'test'},  'this thing']
        data.to_html.should == '<p class="test">this thing</p>'
      end

      it 'entags properties around interleaved tag arrays' do
        data = [[:a, [:b], {:foo => :bar}]]
        data.to_html.should == '<a foo="bar"><b /></a>'
      end

      it 'collects multiple hashes in to a single list of properties' do
        data = [[:a, {:foo => :bar}, {:baz => 'quux!'}]]
        data.to_html.should match(/baz="quux!"/)
        data.to_html.should match(/foo="bar"/)
      end

      it 'overrides properties which have already been defined to the left' do
        data = [[:a, {:foo => :bar}, {:foo => 'quux!'}]]
        data.to_html.should == '<a foo="quux!" />'
      end

      it 'entags nested arrays' do
        data = [[:a, [:b, {:lol => 'wut'}]]]
        data.to_html.should == '<a><b lol="wut" /></a>'
      end

      it 'entags nested multiple tag arrays' do
        data = [[[:a, [:b, {:lol => 'wut'}]], [:c, [:d, {:no => 'wai'}]]]]
        data.to_html.should == '<a><b lol="wut" /></a><c><d no="wai" /></c>'
      end
    end
  end
end

describe BubbleProperty do
  context 'instantiation' do
    it 'doesn\'t have any values' do
      BubbleProperty.new.keys.should be_empty
    end

    it 'copies values from a provided hash' do
      props = BubbleProperty.new(:a => :b)
      props[:a].should == :b
    end

    it 'raises an error when an unhashable value is provided' do
      lambda { BubbleProperty.new('I\'m a string!') }.should raise_error(ArgumentError)
    end

    it 'occurs when Hash#to_fragment_property is called' do
      hash = {:c => 45, 'other' => Class}
      prop = hash.to_fragment_property
      prop.keys.each{ |k| hash[k].should == prop[k] }
    end
  end

  context 'rendering' do
    it 'returns an HTML property string' do
      props = BubbleProperty.new(:a => 45)
      props.to_property_string.should == 'a="45"'
    end

    it 'renders multiple properties' do
      new_properties = {:a => 45, 'foo' => 'bar'}
      props = BubbleProperty.new(new_properties)
      props.to_property_string.should == 'foo="bar" a="45"'
    end

    it 'occurs when Hash#to_property_string is called' do
      {:a => 45, 'foo' => 'bar'}.to_property_string.should == 'foo="bar" a="45"'
    end
  end
end
