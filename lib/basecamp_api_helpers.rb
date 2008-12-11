module BasecampAPIHelpers

  def add_triple(source_id, object_id, attrib, value, update_type='query')
    puts "#{source_id}, #{object_id}, #{attrib}, #{value}, #{update_type}\n"
    o=ObjectValue.new
    o.source_id=source_id
    o.object=object_id
    o.attrib=attrib
    
    # handle value = {"nil"=>"true"}
    if (value.class == String)
      o.value= value
    else
      o.value= nil
    end
  
    o.update_type=update_type
    
    if !o.save
      puts "failed creating triple #{source_id}, #{object_id}, #{attrib}, #{value}, #{update_type}"
    end
  end
    
end