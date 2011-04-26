class Bubble < Array
  def to_fragment
    self
  end

  def to_html
    if first.is_a?(Array) 
      self.each do |x|
        unless x.is_a?(Array)
          raise ArgumentError.new(":#{x.to_s} is not a valid tag array.  Did you mean [:#{x.to_s}]?")
        end
      end
      map{|x| x.to_html }.join # traverse
    else
      self.to_tag #descend
    end
  end

  def to_tag
    return '' if empty?
    if self.size == 1
      return self[0].is_a?(Symbol) ? "<#{self[0].to_s} />" : self[0]
    end

    list = reject{ |x| x.is_a?(Hash) }
    head, tail = list.bite_off_head

    fore_tag = [head.to_s, properties.to_property_string].compact.reject{ |x| x.empty? }.join(' ')

    return "<#{fore_tag} />" if tail.nil? || tail.empty?
    "<#{fore_tag}>#{tail.to_html}</#{head}>"
  end

  def properties
    self.inject({}) { |acc, elem| acc.merge!(elem) if elem.is_a?(Hash); acc }
  end

  def bite_off_head
    return self[0], self[1..-1]
  end
end

class BubbleProperty < Hash
  def initialize(data = {})
    if data.respond_to?(:keys)
      data.keys.each{|k| self[k] = data[k]}
    else
      raise ArgumentError, "Couldn't instantiate BubbleProperty; I expected a Hash-y object."
    end
  end

  def to_property_string
    self.map{ |k, v| "#{k.to_s}=\"#{v.to_s}\""}.join(' ')
  end
end

class Array
  def to_fragment
    Bubble.new(self)
  end

  def to_html
    self.to_fragment.to_html
  end
end

class Hash
  def to_fragment_property
    BubbleProperty.new(self)
  end

  def to_property_string
    self.to_fragment_property.to_property_string
  end
end

class String
  def to_html
    self
  end
end

