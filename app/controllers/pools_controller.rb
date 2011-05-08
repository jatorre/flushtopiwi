CartoDB::Settings   = YAML.load_file("#{File.dirname(__FILE__)}/config/cartodb_config.yml")[ENV["RACK_ENV"]] unless defined? CartoDB::Settings
CartoDB::Connection = CartoDB::Client::Connection.new unless defined? CartoDB::Connection

class PoolsController < ApplicationController

  def show
    #Check if the uuid is in cartodb or not
    sql ="select * from mapbrd where uuid = '#{@uuid.gsub(/\\/, '\&\&').gsub(/'/, "''")}'"
    
    @cartodb = CartoDB::Connection
    result = @cartodb.query(sql)
    
    if result.rows.empty?
      sql= "INSERT INTO mapbrd(uuid) VALUES('#{@uuid.gsub(/\\/, '\&\&').gsub(/'/, "''")}')"
      @cartodb.query(sql)
        @geojson_data ="{}"
    else
      if result.rows.first.the_geom.blank?
        @geojson_data ="{}"
      else
        @geojson_data = result.rows.first.the_geom
      end
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => "feo" }
    end
    
  end
  
  def new    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => "feo" }
    end
  end

  def save
    debugger
    sql= "INSERT INTO piwi(id) VALUES(1)"
    @cartodb = CartoDB::Connection
    result = @cartodb.query(sql)
    
#    sql = "INSERT INTO piwi(uid,the_geom) VALUES (ST_GeomFromText('#{params[:wkt]}', '4326')"
    sql = "UPDATE piwi SET the_geom=ST_GeomFromText('#{params[:wkt]}', '4326') WHERE id = 1"
    puts sql
    @cartodb = CartoDB::Connection
    result = @cartodb.query(sql)
    
    respond_to do |format|
      format.json { render :json => result.to_json }
    end
  end  

end
