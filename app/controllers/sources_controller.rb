require 'soap/wsdlDriver'
require 'digest/md5'

class SourcesController < ApplicationController

  # helper function to come up with the string used for the hash
  # avhash has jasj
  def hashstring(h)
    result="{"
    h.keys.each do |x|
      result << (x +"=>" + h[x] + ",")
    end
    result=result[0...size-1] # chop off the last comma!
    result += "}"
  end

  # this connect to the web service of the given source backend and:
  # - does a prolog (generally logging in)
  # - does updating of records as required
  # - reads records from the backend
  # - does an epilog (logs off)
  def refresh

    @source=Source.find params[:id]
    client = SOAP::WSDLDriverFactory.new(@source.url).create_rpc_driver
    # make sure to use client and session_id variables
    # in your code that is edited into each source!
    callbinding=eval(@source.prolog+";binding")

    # first do all the the creates
    if @source.createcall and @source.createcall.size>0
      objvals=ObjectValue.find_by_update_type("create")
      createobjects=objvals.map {|x| x.object }
      createobjects=createobjects.uniq
      # createobjects is all the distinct objects that are marked for create
      createobjects.each do |x|
        objvals=ObjectValue.find_by_object(x)  # this has all the attribute value pairs now
        attrvalues={}
        objvals.each do |x|
          attrvalues[x.attribute]=x.value
        end
        # now attrvalues has the attribute values needed for the createcall
        avstring=hashstring(attrvalues)
        callbinding=eval("attrvals="+avstring+";"+@source.createcall+";binding",callbinding)
      end
    end

    # now do the updates
    if @source.updatecall and @source.updatecall.size>0
      objvals=ObjectValue.find_by_update_type("update")
      updateobjects=objvals.map {|x| x.object }
      updateobjects=updateobjects.uniq
      updateobjects.each do |x|
        objvals=ObjectValue.find_by_object(x)  # this has all the attribute value pairs now
        attrvalues={}
        objvals.each do |x|
          attrvalues[x.attribute]=x.value
        end
        # now attrvalues has the attribute values needed for the createcall
        avstring=hashstring(attrvalues)
        callbinding=eval("attrvals="+avstring+";"+@source.updatecall+";binding",callbinding)
      end
    end


    # now do the deletes
    if @source.updatecall and @source.updatecall.size>0
      objvals=ObjectValue.find_by_update_type("delete")
      deleteobjects=objvals.map {|x| x.object }
      deleteobjects.each do |x|
        callbinding=eval("deleteobj="+x+";"+@source.deletecall+";binding",callbinding)
      end
    end

    if @source.call
      # now do the query call
      callbinding=eval(@source.call+";binding",callbinding)
      # now take apart the returned data 
      callbinding=eval(@source.sync,callbinding)
    end
    
    # now do the logoff
    callbinding=eval(@source.epilog+ ";binding",callbinding) if @source.epilog
    eval(@source.sync,callbinding)
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

  # GET /sources/1
  # GET /sources/1.xml
  def show
    @source = Source.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @source }
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
