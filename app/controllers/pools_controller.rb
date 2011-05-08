CartoDB::Settings   = YAML.load_file("#{File.dirname(__FILE__)}/config/cartodb_config.yml")[ENV["RACK_ENV"]] unless defined? CartoDB::Settings
CartoDB::Connection = CartoDB::Client::Connection.new unless defined? CartoDB::Connection

class PoolsController < ApplicationController

  def show
    @uuid = params[:uuid]
    
    #Check if the uuid is in cartodb or not
    sql ="select * from mapbrd where uuid = '#{@uuid.gsub(/\\/, '\&\&').gsub(/'/, "''")}'"
    
    @cartodb = CartoDB::Connection
    result = @cartodb.query(sql)
    
    if result.rows.empty?
      
      @area = 15122
      # @area = Random.new.rand(9220..17517)
      sql = "SELECT id_4,ST_XMax(Box2D(the_geom)) as xmax,ST_YMax(Box2D(the_geom)) as ymax,
      ST_XMin(Box2D(the_geom)) as xmin,ST_YMin(Box2D(the_geom)) as ymin FROM adm4 where id_4=#{@area}"
      @cartodb = CartoDB::Connection
      result = @cartodb.query(sql)


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
    
    @area = 15122
    # @area = Random.new.rand(9220..17517)
    sql = "SELECT id_4,ST_XMax(Box2D(the_geom)) as xmax,ST_YMax(Box2D(the_geom)) as ymax,
    ST_XMin(Box2D(the_geom)) as xmin,ST_YMin(Box2D(the_geom)) as ymin FROM adm4 where id_4=#{@area}"
    @cartodb = CartoDB::Connection
    result = @cartodb.query(sql)

    @data = result.rows.first

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
