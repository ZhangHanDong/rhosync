require 'soap/wsdlDriver'
require 'digest/md5'

class SourcesController < ApplicationController


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
    callbinding=eval(@source.updatecall+";binding",callbinding) if @source.updatecall
    callbinding=eval(@source.call+";"+ @source.epilog+ ";binding",callbinding)
    #result=eval("result",callbinding  - THIS IS TO JUST GET DATA RESULTS
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