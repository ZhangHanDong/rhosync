require 'soap/wsdlDriver'
require 'digest/md5'

class SourcesController < ApplicationController

=begin
How to query Sugar
   1. session_id, what we get after using login()
   2. module_name, that is Contacts,Accounts,Notes,Cases etc
   3. query, a sql like query
   4. order_by, a sql like order by clause
   5. offset, to obtain something like a pagination
   6. select_fields, array of fields to be retrieved
   7. max_result, max number of entries to retrieve
   8. deleted, whether to show also deleted entries or not
=end


  def refresh

    @source=Source.find params[:id]
    client = SOAP::WSDLDriverFactory.new(@source.url).create_rpc_driver
    # make sure to use client and session_id variables in your code
    #session_id=eval(@source.prolog) if @source.prolog and @source.prolog.size>0
    callbinding=eval(@source.prolog+@source.call+";binding")

    #result=eval("result",callbinding
    eval(@source.sync,callbinding)

    redirect_to :action=>"edit"
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
