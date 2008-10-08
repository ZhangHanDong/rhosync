require 'soap/wsdlDriver'
require 'digest/md5'
require 'yaml'

class SourcesController < ApplicationController

  include SourcesHelper
  # shows all object values in XML structure given a supplied source
  # if a :last_update parameter is supplied then only show data that has been
  # refreshed (retrieved from the backend) since then


  protect_from_forgery :only => [:create, :delete, :update]

  def show
    last_update_time=Time.parse(params[:last_update]) if params[:last_update]
    @source=Source.find params[:id]
    # if we have a last_update parameter then only do the update
    # if the last update time is before the most recent refresh then bring back values
    if !last_update_time or (@source.refreshtime and (last_update_time<=>@source.refreshtime)<0)
      @object_values=ObjectValue.find_all_by_update_type_and_source_id "query",params[:id]
    else  # no need to bring back values because we're still waiting for a refresh on the server!
      @object_values=nil
    end
    respond_to do |format|
      format.html
      format.xml  { render :xml => @object_values}
      format.json { render :json => @object_values}
    end
  end

  # this creates all of the rows in the object values table corresponding to
  # the array of hashes given by the attrvals parameter
  # note that the REFRESH action below will later DELETE all of the created records
  #
  # also note YOU MUST CREATE A TEMPORARY OBJECT ID. Some form of hash or CRC
  #  of all of the values can be used
  #
  # for example
  # :attrvals=
  #   [{"object"=>"temp1","attrib"=>"name","value"=>"rhomobile"},
  #   {"object"=>"temp1","attrib"=>"industry","value"=>"software"},
  #   {"object"=>"temp1","attrib"=>"employees","value"=>"500"}
  #   {"object"=>"temp2","attrib"=>"name","value"=>"mobio"},
  #   {"object"=>"temp2","attrib"=>"industry","value"=>"software"},
  #   {"object"=>"temp3","attrib"=>"name","value"=>"xaware"},
  #   {"object"=>"temp3","attrib"=>"industry","value"=>"software"}]
  #
  # RETURNS:
  #   a hash of the object_values table ID columns as keys and the updated_at times as values
  def createobjects
    @source=Source.find params[:id]
    objects={}
    params[:attrvals].each do |x| # for each hash in the array
       # note that there should NOT be an object value for new records
       o=ObjectValue.new
       o.object=x["object"]
       o.attrib=x["attrib"]
       o.value=x["value"]
       o.update_type="create"
       o.source=@source
       o.save
       # add the created ID + created_at time to the list
       objects[o.id]=o.created_at if not objects.keys.index(o.id)  # add to list of objects
    end

    respond_to do |format|
      format.html { render :xml => objects }
      format.xml  { render :xml => objects }
      format.json  { render :json => objects }
    end
  end

  # this creates all of the rows in the object values table corresponding to
  # the array of hashes given by the attrval parameter.
  # note that the REFRESH action below will later DELETE all of the created records
  #  # for example
  # :attrvals=
  #   [{"object"=>"1","attrib"=>"name","value"=>"rhomobile"},
  #   {"object"=>"1","attrib"=>"industry","value"=>"software"},
  #   {"object"=>"1","attrib"=>"employees","value
  #   {"object"=>"2","attrib"=>"name","value"=>"mobio"},
  #   {"object"=>"2","attrib"=>"industry","value"=>"software"},
  #   {"object"=>"3","attrib"=>"name","value"=>"xaware"},
  #   {"object"=>"3","attrib"=>"industry","value"=>"software"}]
  #
  # RETURNS:
  #   a hash of the object_values table ID columns as keys and the updated_at times as values
  def updateobjects
    @source=Source.find params[:id]
    objects={}
    params[:attrvals].each do |x|  # for each hash in the array
       o=ObjectValue.new
       o.object=x["object"]
       o.attrib=x["attrib"]
       o.value=x["value"]
       o.update_type="update"
       o.source=@source
       o.save
       # add the created ID + created_at time to the list
       objects[o.id]=o.created_at if not objects.keys.index(o.id)  # add to list of objects
    end

    respond_to do |format|
      format.html { render :xml => objects }
      format.xml  { render :xml => objects }
      format.json  { render :json => objects }
    end
  end

  # this creates all of the rows in the object values table corresponding to
  # the hash given by attrvals.
  # note that the REFRESH action below will later DELETE all of the created records
  #
  # RETURNS:
  #   a hash of the object_values table ID columns as keys and the updated_at times as values
  def deleteobjects
    @source=Source.find params[:id]
    objects={}
    params[:attrvals].each do |x|
       o=ObjectValue.new
       o.object=x["object"]
       o.attrib=x["attrib"] if x["attrib"]
       o.value=x["value"] if x["value"]
       o.update_type="delete"
       o.source=@source
       o.save
       # add the created ID + created_at time to the list
       objects[o.id]=o.created_at if not objects.keys.index(o.id)  # add to list of objects
    end

    respond_to do |format|
      format.html do
            flash[:notice]="Deleted objects"
            redirect_to :action=>"show"
      end
      format.xml  { render :xml => objects }
      format.json { render :json => objects }
    end
  end

  # this creates a view that "flattens" the object values into a view that
  # has each attribute as a separate column
  # for example
  #     create view account_names as
  #select value as name,object
  # from object_values
  # where attrib='name';
  # create view account_industries as
  # select value as name,object
  # from object_values
  # where attrib='industry';
  # create view account_all as
  # select account_names.object,account_names.name,account_names.industry
  # from account_names, account_industries
  # where account_names.object=account_industries.object;
  def flat_view
    sql

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

  # this create the set of INSERT statements to be executed to populate the
  # an "app/source specific table" (usable by an ORM on top of SQLITE on the device)
  # from the object values table
  # TODO: investigate if we can do this with a view
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


  def pick_load
    # go to the view to pick the file to load
  end

  def load_all
    # NOTE: THIS DOES NOT WORK FROM OUR SAVING FORMAT RIGHT NOW! (the one that save_all does)
    # it only works from the YAML format in db/migrate/sources.yml
    # this is a very well reported upon Ruby/YAML issue
    @sources=YAML::load_file params[:yaml_file]
    p @sources
    @sources.keys.each do |x|
      source=Source.new(@sources[x])
      source.save
    end
    flash[:notice]="Loaded sources"
    redirect_to :action=>"index"
  end

  def pick_save
    # go to the view to pick the file
  end

  def save_all
    @sources=Source.find :all
    File.open(params[:yaml_file],'w') do |out|
      @sources.each do |x|
        YAML.dump(x,out)
      end
    end
    flash[:notice]="Saved sources"
    redirect_to :action=>"index"
  end


  # this connects to the web service of the given source backend and:
  # - does a prolog (generally logging in)
  # - does creating, updating, deleting of records as required
  # - reads (queries) records from the backend
  # - does an epilog (logs off)
  #
  # it should be invoked on a scheduled basis by some admin process,
  # generally using CURL.  it should also be done with a separate instance
  # than the one used to service create, update and delete calls from the client
  # device
  def refresh
    @source=Source.find params[:id]
    # not all endpoints require WSDL!
    client = SOAP::WSDLDriverFactory.new(@source.url).create_rpc_driver if @source.url and @source.url.size>0
    # make sure to use client and session_id variables
    # in your code that is edited into each source!
    callbinding=eval %"#{@source.prolog};binding"

    # first do all the the creates
    if @source.createcall and @source.createcall.size>0
      creates=ObjectValue.find_by_sql("select * from object_values where update_type='create'")
      uniqobjs=creates.map {|x| x.object}
      uniqobjs.uniq!
      uniqobjs.each do |x|
        p "Searching for attribute values for object: "+x
        xvals=ObjectValue.find_all_by_object(x)  # this has all the attribute value pairs for this particular object
        if xvals.size>0
          attrvalues={}
          xvals.each do |y|
            p "Attribute: " + y.attrib
            p "Value: " + y.value
            attrvalues[y.attrib]=y.value if y.attrib and y.value
            y.destroy
          end
          # now attrvalues has the attribute values needed for the createcall
          # the Sugar adapter will use the name_value_list variable that we're building up here
          # TODO: name_value_list is probably too specific to Sugar
          #  need a clean way to pass the attrvalues hash to any source adapter cleanly
          p "Attributes hash size: " + attrvalues.size.to_s
          nvlist=make_name_value_list(attrvalues)
          callbinding=eval("name_value_list="+nvlist+";"+@source.createcall+";binding",callbinding)
        end

      end
    end

    # now do the updates
    if @source.updatecall and @source.updatecall.size>0
      updates=ObjectValue.find_by_sql("select * from object_values where update_type='update'")
      uniqobjs=updates.map {|x|x.object}
      uniqobjs.uniq!
      uniqobjs.each do |x|
        objvals=ObjectValue.find_all_by_object(x)  # this has all the attribute value pairs now
        attrvalues={}
        attrvalues["id"]=x  # setting the ID allows it be an update
        objvals.each do |y|
          attrvalues[y.attrib]=y.value
          y.destroy
        end
        # now attrvalues has the attribute values needed for the createcall
        nvlist=make_name_value_list(attrvalues)
        callbinding=eval("name_value_list="+nvlist+";"+@source.updatecall+";binding",callbinding)

      end
    end

    # now do the deletes
    if @source.updatecall and @source.updatecall.size>0
      deletes=ObjectValue.find_by_sql("select * from object_values where update_type='delete'")
      uniqobjs=deletes.map {|x|x.object}
      uniqobjs.uniq!
      uniqobjs.each do |x|
        attrvalues={}
        attrvalues["id"]=x
        nvlist=make_name_value_list(attrvalues)
        callbinding=eval("namevaluelist="+nvlist+";"+@source.deletecall+";binding",callbinding)
        x.destroy
      end
    end

    if @source.call
      # now do the query call
      p "Executing query call"
      callbinding=eval(@source.call+";binding",callbinding)
      # delete the old source records
      ObjectValue.delete_all "update_type='query' and source_id="+@source.id.to_s
      # now take apart the returned data and fill the object values table
      p "Executing backend data sync"
      callbinding=eval(@source.sync,callbinding) if @source.sync
    end

    # now do the logoff
    callbinding=eval(@source.epilog+ ";binding",callbinding) if @source.epilog and @source.epilog.size>0

    @source.refreshtime=Time.new  # keep track of the refresh time to help optimize show queries
    @source.save

    redirect_to :action=>"show",:id=>@source.id
  end


  # GET /sources
  # GET /sources.xml
  def index
    @sources = Source.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sources }
    end
  end


  # GET /sources/new
  # GET /sources/new.xml
  def new
    @source = Source.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @source }
    end
  end

  # GET /sources/1/edit
  def edit
    @source = Source.find(params[:id])
    render :action=>"edit"
  end

  # POST /sources
  # POST /sources.xml
  def create
    @source = Source.new(params[:source])

    respond_to do |format|
      if @source.save
        flash[:notice] = 'Source was successfully created.'
        format.html { redirect_to(@source) }
        format.xml  { render :xml => @source, :status => :created, :location => @source }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sources/1
  # PUT /sources/1.xml
  def update
    @source = Source.find(params[:id])

    respond_to do |format|
      begin
        if @source.update_attributes(params[:source])
          @source.save_to_yaml
          flash[:notice] = 'Source was successfully updated.'
          format.html { redirect_to(@source) }
          format.xml  { head :ok }
        else
          begin  # call underlying save! so we can get some exceptions back to report
            # (update_attributes just calls save
            @source.save!
          rescue Exception
            flash[:notice] = $!
          end

          format.html { render :action => "edit" }
          format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
        end
      end
    end

  end

  # DELETE /sources/1
  # DELETE /sources/1.xml
  def destroy
    @source = Source.find(params[:id])
    @source.destroy

    respond_to do |format|
      format.html { redirect_to(sources_url) }
      format.xml  { head :ok }
    end
  end
end
