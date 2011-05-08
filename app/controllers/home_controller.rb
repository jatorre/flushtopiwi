class HomeController < ApplicationController
  def index
    
    @uuid = UUIDTools::UUID.timestamp_create().to_s
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => "xml" }
    end
  end
end
