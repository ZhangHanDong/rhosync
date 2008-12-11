class BasecampProjects 
  attr_accessor :client
  
  def initialize(source)
    @source=source
  end

  def login
    # intentionally left blank
  end

  def query
    puts @source.inspect
    uri = URI.parse(@source.url+"/projects.xml")
    req = Net::HTTP::Get.new(uri.path, 'Accept' => 'application/xml')
    req.basic_auth @source.login, @source.password
    response = Net::HTTP.start(uri.host,uri.port) do |http|
      http.request(req)
    end
    xml_data = XmlSimple.xml_in(response.body); 
    @result = xml_data["project"]
  end

  def sync
    @result.each do |project|
      id = project["id"][0]["content"]      

      add_triple(@source.id, id, "name", project["name"][0])
      add_triple(@source.id, id, "status", project["status"][0])
      add_triple(@source.id, id, "company_id", project["company"][0]["id"][0]["content"])
    end
  end

  def create(name_value_list)
  end

  def update(name_value_list)
  end

  def delete(name_value_list)
  end

  def logoff
    # intentionally left blank
  end
  
  protected
  
  def add_triple(source_id, object_id, attrib, value, update_type='query')
    o=ObjectValue.new
    o.source_id=source_id
    o.object=object_id
    o.attrib=attrib
    o.value= value
    o.update_type=update_type
    if !o.save
      puts "failed creating triple #{source_id}, #{object_id}, #{attrib}, #{value}, #{update_type}"
    end
  end
end