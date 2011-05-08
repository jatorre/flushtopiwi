// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var map;
var lat = 40.42238718089105;
var lng = -3.6995601654052734;
var flag = 0;
var bounds = new GLatLngBounds();

var zoomFactor = 14;

var polygons_in_map=[];

function saveMap() {
  
  $("#saveButton").val(".....");
  
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
  var data_to_send = {area:$("#area").val(),wkt:wkt};
  
  $.ajax({
    type: "POST",
    url: "/save",
    data: data_to_send,
    success: function(){
      $("#saveButton").val("save map");
    },
    error: function(){
      alert("ha ocurrido un error");
    }
  });
}

function polygonConstructor(coords,enable_drawing) {
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
    
    bounds.extend(new GLatLng(data.ymin, data.xmin));
    bounds.extend(new GLatLng(data.ymax, data.xmax));
    map.setCenter(bounds.getCenter(), 16);  
    map.setUIToDefault();

});