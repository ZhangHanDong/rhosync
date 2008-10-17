module SourcesHelper

    # logon to Sugar
  def sugar_logon(user,password)
    u = user
    p = Digest::MD5.hexdigest(password)
    ua = {"user_name" => u,"password" => p}
    wsdl = "http://yoursite.com/soap.php?wsdl"
    #create soap
    s = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    #uncomment this line for debugging. saves xml packets to files
    s.wiredump_file_base = "soapresult"
    #create session
    ss = s.login(ua,nil)
    #check for login errors
    if ss.error.number.to_i != 0
	#status message
	p "failed to login - #{ss.error.description}"
	#exit program
	return nil
    else
	#get id
	sid = ss['id']
	#get current user id
	uid = s.get_user_id(sid)
	#status message
	puts "logged in to session #{sid} as #{u} (#{uid}) "

        return sid
    end
  end

  def sugar_logout
    s.logout
  end

  # helper function to come up with the string used for the name_value_list
  # name_value_list =  [ { "name" => "name", "value" => "rhomobile" },
  #                     { "name" => "industry", "value" => "software" } ]
  def make_name_value_list(hash)
    if hash and hash.keys.size>0
      result="["
      hash.keys.each do |x|
        result << ("{'name' => '"+ x +"', 'value' => '" + hash[x] + "'},")
      end
      result=result[0...result.size-1]  # chop off last comma
      result += "]"
    end
  end


    # Generate the SQL CREATE statement
  # to create a table which is an "app/source specific table"
  # (usable by an ORM on top of SQLITE on the device)
  # based on all of the attributes present in the object values table
  #
  # RETURNS:
  #   XMLified or Jsonified string containing the SQL CREATE statement
  def table_create
    @source=Source.find params[:id]

    objectvals=ObjectValue.find_all_by_source_id @source.id
    colnames=[]
    objectvals.each do |x|  # each attrib is a column name
      colnames << x.attrib if x.attrib and !colnames.index(x.attrib)
    end
    result="DROP TABLE "+@source.name + ";"
    result+="CREATE TABLE "+@source.name + "(id INTEGER PRIMARY KEY,"
    colnames.each do |x|
      result = result + x + " VARCHAR(255)," if x
    end
    result=result[0...result.size-1]  # chop off that last comma
    result = result + ");"

    respond_to do |format|
      format.html { render :xml => result}
      format.xml  { render :xml => result }
      format.json  { render :json => result }
    end
  end

  # the calls below create tables from the object values table property bag
  # they aren't really necessary now given the presence of Rhom

  # this create the set of INSERT statements to be executed to populate the
  # an "app/source specific table" (usable by an ORM on top of SQLITE on the device)
  # from the object values table
  #
  # RETURNS:
  #   an array of INSERT strings inside JSON or XML
  def table_inserts
    @source=Source.find params[:id]
    objectvals=ObjectValue.find_all_by_source_id @source.id

    # first find all the column names
    # TODO: inefficient, should be separate select of just the colnames
    colnames=[]
    objectvals.each do |x|  # each attrib is a column name
      colnames << x.attrib if x.attrib and !colnames.index(x.attrib)
    end

    # based on those column names formulate the INSERT statement starting text to be used for all INSERTs below
    insertstart="INSERT INTO " + @source.name + " ("
    colnames.each do |colname|
      insertstart+=(colname+",")
    end
    insertstart=insertstart[0...insertstart.size-1] # chop off the comma
    insertstart+=") VALUES("

    # get the list of distinct objects, which will be rows in the new table
    objects=objectvals.map {|x| x.object}
    objects.uniq!  # all the distinct objects in the object values array
    # now go create all the insert statements based on the object values
    @inserts=[]
    objects.each do |x|
      sql=insertstart
      xvals = ObjectValue.find_all_by_object x # only use the values for this object x!

      valuelist=[]
      colnames.each do |col|
        xvals.each do |xval|
          if xval.attrib==col and !valuelist.index(xval.value)
            sql = sql +"\"" + xval.value + "\","
            valuelist << xval.value
          end
        end
      end
      sql=sql[0...sql.size-1]
      sql+=");"  # chop off the trailing comma and close the VALUES right paren
      @inserts << sql
    end

    respond_to do |format|
      format.html {render :action=>"table_inserts"}
      format.xml  { render :xml => @inserts}
      format.json  { render :json => @inserts }
    end
  end

  # generate updates for the "app/source specific table" described above

  def table_updates
    @source=Source.find params[:id]
    objectvals=ObjectValue.find_all_by_source_id @source.id
    # first find all the column names
    # TODO: inefficient, should be separate select of just the colnames
    colnames=[]
    objectvals.each do |x|  # each attrib is a column name
      colnames << x.attrib if x.attrib and !colnames.index(x.attrib)
    end

    # get the list of distinct objects, which will be rows in the new table
    objects=objectvals.map {|x| x.object}
    objects.uniq!  # all the distinct objects in the object values array

    # based on those column names formulate the INSERT statement starting text to be used for all INSERTs below
    updatestart="UPDATE " + @source.name + " SET "

    # now go create all the update statements based on the object values
    @updates=[]
    objectid=nil
    objects.each do |x|  # each value is a column name
      sql=updatestart
      xvals = ObjectValue.find_all_by_object x # only use the values for this object x!
      valuelist=[]
      colnames.each do |col|
        xvals.each do |xval|
          if xval.attrib==col and !valuelist.index(xval.value)
            sql = sql + col +"=\"" + xval.value + "\","
            valuelist << xval.value
          end
          objectid=xval.value if xval.attrib.downcase=="id"
        end
      end
      sql=sql[0...sql.size-1]  # chop last comma off
      sql += " WHERE ID=" + objectid + ";"
      @updates << sql if objectid  # only add if we got an ID to use for the object
    end

    respond_to do |format|
      format.html { render :action => "table_updates"}
      format.xml  { render :xml => @updates }
      format.json  { render :json => @updates }
    end
  end

end
