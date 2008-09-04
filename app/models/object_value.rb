require "xml/libxml"

class ObjectValue < ActiveRecord::Base

  # take arbitrary XML and serialize it into this table of objects and values
  def self.serialize(xml)
    p "Serializing " + xml
    xp = XML::Parser.string(xml)
    doc = xp.parse
    root=doc.root
    current=root
    current.children.each do |x|
      p "Name:" + x.name
    end
  end
end
