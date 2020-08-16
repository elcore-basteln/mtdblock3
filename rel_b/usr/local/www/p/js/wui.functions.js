$(document).bind("mobileinit", function(){
  $.mobile.ajaxEnabled = false;
  $.mobile.pushStateEnabled = false;
});

var wui = {
  show_time: function(id, ts) {
    var d = new Date();
    d.setTime(ts * 1000); 
    document.getElementById(id).innerHTML = d.getDate()+"."+(1+d.getMonth())+"."+(1900+d.getYear())+" "+d.getHours()+":"+d.getMinutes()+":"+d.getSeconds();
  },
  show_bar: function(id, v, m) {
    document.getElementById(id).setAttribute("style", "width:"+Math.ceil(v*100/m)+"%");
  },
  set_lang: function(sid, l) {
    $.get("access.cgi?"+sid+"&action=language&lang="+l, function(data){window.location.reload();});
  },  
  
  ajax : {
    dataSend : function (url, msg, cb){
        var h = false;
        if (window.XMLHttpRequest) { // Mozilla, Safari,...
            h = new XMLHttpRequest();
        } else if (window.ActiveXObject) { // IE
        	try {h = new ActiveXObject("Msxml2.XMLHTTP");
        	}catch (e){
        	    try {h = new ActiveXObject("Microsoft.XMLHTTP");
        	    } catch (e) {}
        	}
        }
        if (h){
            h.open('POST', url, true);
            h.onreadystatechange = function(){
                if (h.readyState == 4 && h.status == 200){
                    cb(h.responseText);
                } 
            };
            //http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            h.setRequestHeader("Content-Type", "text/plain;charset=UTF-8");
        	h.send(msg);
        }
     },
     dataGet : function (url, msg){
        var h = false;
        if (window.XMLHttpRequest) { // Mozilla, Safari,...
            h = new XMLHttpRequest();
        } else if (window.ActiveXObject) { // IE
        	try {h = new ActiveXObject("Msxml2.XMLHTTP");
        	}catch (e){
        	    try {h = new ActiveXObject("Microsoft.XMLHTTP");
        	    } catch (e) {}
        	}
        }
        if (h){
            h.open('POST', url, false);
            //http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            h.setRequestHeader("Content-Type", "text/plain;charset=UTF-8");
            h.send(msg);
            //alert(h.responseText);
            return JSON.parse(h.responseText);
        }
     }
  },

  value : {
    trim : function(s){
                return s.replace(/ /g, "");
    },
    isInt: function(v){ 
                if((parseFloat(v) == parseInt(v)) && !isNaN(v)) return true;
                return false;
    },
    isInRange: function(val,min,max){
        if(wui.value.isInt(val))
            if(val>=min && val<=max)
                return true;
        return false;
    }
  }
}
