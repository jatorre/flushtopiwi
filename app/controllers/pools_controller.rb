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
    
#    preselected_areas =[234234,2343,222,56767,6212155,67852,985342]
    
#    id = preselected_areas[rand(10)]
#    id = preselected_areas[rand(preselected_areas.length)]
    
#    sql ="select * from adm4 where areaid = '#{id.gsub(/\\/, '\&\&').gsub(/'/, "''")}'"
#    @cartodb = CartoDB::Connection
#    result = @cartodb.query(sql)

    @area = 1

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => "feo" }
    end
  end

  def save
    
    sql = "INSERT INTO mapbrd(gadm4_id_4, the_geom) VALUES ('#{@area}', ST_GeomFromText('#{params[:wkt]}', '4326'))"
    puts sql
    @cartodb = CartoDB::Connection
    result = @cartodb.query(sql)
    
    respond_to do |format|
      format.json { render :json => result.to_json }
    end
  end  

end
