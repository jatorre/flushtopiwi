// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var map;
var lat = 40.42238718089105;
var lng = -3.6995601654052734;
var flag = 0;
var bounds = new GLatLngBounds();

var zoomFactor = 14;

var polygons_in_map=[];

function drawPolygons() {
  
  var _bounds = new GLatLngBounds();
  if (geojson_data.coordinates) {
    $.each(geojson_data.coordinates, function(index, poly) { 
      var _coords=[];
      $.each(poly[0], function(index, c) {
        _coords.push(new GLatLng(c[1], c[0]));
        _bounds.extend(new GLatLng(c[1], c[0])); 
      });
      polygons_in_map.push(polygonConstructor(_coords,false)); 
      
    });
    map.setCenter(_bounds.getCenter(), map.getBoundsZoomLevel(_bounds));  
  }
  
}

function saveMap() {
    
  var polygons_arr=[];
  
  $.each(polygons_in_map, function(index, polygon) { 
     coordinates = [];
     for (var v = 0; v < polygon.getVertexCount(); v++) {
       var lat = polygon.getVertex(v).lat();
       var lng = polygon.getVertex(v).lng();
       coordinates.push([lng + " " + lat]);
     }
     polygons_arr.push(coordinates.join(","));
  });
  
  var wkt = "MULTIPOLYGON((("+polygons_arr.join(")),((")+")))";  
  var data_to_send = {uuid:uuid,wkt:wkt};
  
  $.ajax({
    type: "POST",
    url: "/save",
    data: data_to_send,
    success: function(){
    },
    error: function(){
      alert("ha ocurrido un error");
    }
  });
}

function polygonConstructor(coords,enable_drawing) {
  //var polygon = new GPolygon(coords,"#DA2B39",1,1,"#DA2B39",0.6);
  var polygon = new GPolygon(coords);
  map.addOverlay(polygon);
  if(enable_drawing) {
    polygon.enableDrawing();
  }
  polygon.enableEditing({onEvent: 'mouseover'});
  
  GEvent.addListener(polygon, "cancelline", function() {});
  GEvent.addListener(polygon, "endline", function() {
    if (flag == 1) {
      saveMap();
      flag = 0;
    }
  });
  
  if (!enable_drawing) {
    GEvent.addListener(polygon, "lineupdated", function() { saveMap(); }); 
  }

  return   polygon;
}

function createPolygon() {
  flag = 1;
  polygons_in_map.push(polygonConstructor([],true));
}


$(document).ready(function(){
    
    map = new GMap2(document.getElementById("map"));
    map.setMapType(G_SATELLITE_MAP);
    map.addControl(new GLargeMapControl3D());
    
    bounds.extend(new GLatLng(bbox.ymin, bbox.xmin));
    bounds.extend(new GLatLng(bbox.ymax, bbox.xmax));
    map.setCenter(bounds.getCenter(), 16);  
    //map.setUIToDefault();
    
    drawPolygons();

});