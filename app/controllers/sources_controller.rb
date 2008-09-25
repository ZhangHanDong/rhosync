require 'soap/wsdlDriver'
require 'digest/md5'
require 'yaml'

class SourcesController < ApplicationController

  include SourcesHelper
  # shows all object values in XML structure given a supplied source
  def show
    @source=Source.find params[:id]
    @object_values=ObjectValue.find_all_by_update_type_and_source_id "query",params[:id]

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @object_values}
    end
  end

  # this creates all of the rows in the object values table corresponding to
  # the array of hashes given by the attrvals parameter
  # note that the REFRESH action below will later DELETE all of the created records
  # 
  # also note that there is no object identifier during the create. so
  # you can leave out the "object" hash key as it will be ignored
  # 
  # for example
  # :attrvals=
  #   [{"object"=>nil,"attrib"=>"name","value"=>"rhomobile"},
  #   {"object"=>nil,"attrib"=>"industry","value"=>"software"},
  #   {"attrib"=>"employees","value
  #   {"attrib"=>"name","value"=>"mobio"},
  #   {"attrib"=>"industry","value"=>"software"},
  #   {"object"=>nil,"attrib"=>"name","value"=>"xaware"},
  #   {"object"=>nil,"attrib"=>"industry","value"=>"software"}]
  #
  # RETURNS:
  #   a hash of the object_values table ID columns as keys and the updated_at times as values
  def createobjects
    source=Source.find params[:id]
    objects={}
    params[:attrvals].each do |x| # for each hash in the array
       # note that there should NOT be an object value for new records
       o=ObjectValue.new
       o.attrib=x["name"]
       o.value=x["value"]
       o.update_type="create"
       o.source=source
       o.save
       # add the created ID + created_at time to the list
       objects[o.id]=o.created_at if not objects.keys.index(o.id)  # add to list of objects
    end

    respond_to do |format|
      format.html { render :xml => objects }
      format.xml  { render :xml => objects }
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
    source=Source.find params[:id]
    objects={}
    params[:attrvals].each do |x|  # for each hash in the array
       o=ObjectValue.new
       o.object=x["object"]
       o.attrib=x["attrib"]
       o.value=x["value"]
       o.update_type="update"
       o.source=source
       o.save     
       # add the created ID + created_at time to the list
       objects[o.id]=o.created_at if not objects.keys.index(o.id)  # add to list of objects
    end

    respond_to do |format|
      format.html { render :xml => objects }
      format.xml  { render :xml => objects }
    end
  end

  # this creates all of the rows in the object values table corresponding to
  # the hash given by attrvals.
  # note that the REFRESH action below will later DELETE all of the created records
  #
  # RETURNS:
  #   a hash of the object_values table ID columns as keys and the updated_at times as values
  def deleteobjects
    source=Source.find params[:id]
    objects={}
    params[:attrvals].each do |x|
       o=ObjectValue.new
       o.object=x["object"]
       o.attrib=x["attrib"]
       o.value=x["value"]
       o.update_type="delete"
       o.source=source
       o.save
       # add the created ID + created_at time to the list
       objects[o.id]=o.created_at if not objects.keys.index(o.id)  # add to list of objects
    end

    respond_to do |format|
      format.html { render :xml => objects }
      format.xml  { render :xml => objects }
    end
  end

  def load_adapter
    # this loads up the yaml file correponding to an individual adapters source code
  end

  def do_load_adapter
    @sources=YAML::load_file params[:yaml_file]
    @sources.keys.each do |x|
      source=Source.new(@sources[x])
      source.save
    end
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
      createobjects=ObjectValue.find_by_sql("select distinct(object) from object_values where update_type='create'")
      if createobjects and createobjects.size>0
        createobjects.each do |x|
          xvals=ObjectValue.find_all_by_object(x)  # this has all the attribute value pairs for this particular object
          attrvalues={}
          xvals.each do |y|
            attrvalues[y.attribute]=y.value
            y.destroy
          end
          # now attrvalues has the attribute values needed for the createcall
          # the Sugar adapter will use the name_value_list variable that we're building up here
          # TODO: name_value_list is probably too specific to Sugar
          # TODO: need a clean way to pass the attrvalues hash to any adapter cleanly
          nvlist=make_name_value_list(attrvalues)
          callbinding=eval("name_value_list="+nvlist+";"+@source.createcall+";binding",callbinding)
        end
      end
    end

    # now do the updates
    if @source.updatecall and @source.updatecall.size>0
      updateobjects=ObjectValue.find_by_sql("select distinct(object) from object_values where update_type='update'")
      if updateobjects and updateobjects.size>0
        updateobjects.each do |x|
          objvals=ObjectValue.find_all_by_object(x)  # this has all the attribute value pairs now
          attrvalues={}
          attrvalues["id"]=x.object  # setting the ID allows it be an update
          objvals.each do |y|
            attrvalues[y.attribute]=y.value
            y.destroy
          end
          # now attrvalues has the attribute values needed for the createcall
          nvlist=make_name_value_list(attrvalues)
          callbinding=eval("name_value_list="+nvlist+";"+@source.updatecall+";binding",callbinding)
        end
      end
    end

    # now do the deletes
    if @source.updatecall and @source.updatecall.size>0
      deleteobjects=ObjectValue.find_by_sql("select distinct(object) from object_values where update_type='delete'")
      if deleteobjects and deleteobjects.size>0
        deleteobjects.each do |x|
          attrvalues={}
          attrvalues["id"]=x.object
          nvlist=make_name_value_list(attrvalues)
          callbinding=eval("namevaluelist="+nvlist+";"+@source.deletecall+";binding",callbinding)
          x.destroy
        end
      end
    end

    if @source.call
      # now do the query call
      p "Executing query call"
      callbinding=eval(@source.call+";binding",callbinding)
      # delete the old source records
      oldobjs=ObjectValue.find_by_sql 'select object,attrib,value from object_values where source_id='+@source.id.to_s
      oldobjs.each do |x| 
        x.destroy
      end
      # now take apart the returned data and fill the object values table
      p "Executing backend data sync"
      callbinding=eval(@source.sync,callbinding) if @source.sync
    end
    
    # now do the logoff
    callbinding=eval(@source.epilog+ ";binding",callbinding) if @source.epilog
 
    redirect_to :controller=>"sources",:action=>"show"
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
      if @source.update_attributes(params[:source])
        flash[:notice] = 'Source was successfully updated.'
        format.html { redirect_to(@source) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
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
