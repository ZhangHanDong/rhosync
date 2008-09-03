require "libxml"

class ObjectValue < ActiveRecord::Base

  # take arbitrary XML and serialize it into this table of objects and values
  def self.serialize(xml)
    xp = XML::Parser.string(xml)
    doc = xp.parse

    doc.children.each do |x|

    end
  end
end
