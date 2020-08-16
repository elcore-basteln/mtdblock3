
var wui = {
  ajax : {
    fileSend : function(f, c) {
		var n = 'f' + Math.floor(Math.random() * 99999);
		var d = document.createElement('div');
		d.innerHTML = '<iframe style="display:none" src="about:blank" id="'+n+'" name="'+n+'" onload="wui.ajax.fileLoaded(\''+n+'\')"></iframe>';
		document.body.appendChild(d);
		var i = document.getElementById(n);
		if (c && typeof(c.onComplete) == 'function') 
            i.onComplete = c.onComplete;
		f.setAttribute('target', n);
        if (c && typeof(c.onStart) == 'function') return c.onStart(); else return true;
	},
	fileLoaded : function(id) {
		var i = document.getElementById(id);
		if (i.contentDocument)
			var d = i.contentDocument;
		else if (i.contentWindow)
			var d = i.contentWindow.document;
		else
			var d = window.frames[id].document;
        if (d.location.href == "about:blank")
			return;
		if (typeof(i.onComplete) == 'function')
			i.onComplete(d.body.innerHTML);
	},
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
  
  element : {
    set : function(id, s) {
        if(!document.getElementById(id)) return;
        var e=document.getElementById(id);
        switch(e.type){
        case 'checkbox': 
            e.checked=(s=='on'?true:false); break;
        case 'radio': 
            var o = document.getElementsByName(id);
            for (var i in o) {
                if(o[i].value == s) {
                    o[i].checked = true;
                    o[i].onchange();
                }
            }
            break;
        case 'text': 
            e.value=s; break;
        case 'select-one':
            for (var i = e.length - 1; i>=0; i--)
                if(e.options[i].value == s){
                    e.options[i].selected=true;
                    if (e.onchange) e.onchange();
                }
            break;
        }
    },
    get : function(id, s) {
        if(!document.getElementById(id)) return "";
        var e=document.getElementById(id);
        switch(e.type){
        case 'checkbox': 
            return e.checked?'on':'off';
        case 'radio': 
            var o = document.getElementsByName(id);
            for (var i in o) {
                if(o[i].checked)
                    return o[i].value;
            }
            break;
        case 'text': 
            return e.value;
        case 'select-one': 
            return e.options[e.selectedIndex].value;
        default:
            return "";
        }
    },
    hide : function(e,h){
        var a=e.split(",");
        for(i in a) {
            var b=a[i].split("-");
            if (b[1])
                for(var j=parseInt(b[0]); j<=parseInt(b[1]) ; j++) try {document.getElementById('line'+j).style.display = h;} catch (e) {}
            else
                try {document.getElementById('line'+b[0]).style.display = h;} catch (e) {}
				
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
    },
	isValidIp: function(val){
        //Remember, this function will validate only Class C IP.
		//change to other IP Classes as you need
		val = val.replace( /\s/g, "") //remove spaces for checking
		var re = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/; //regex. check for digits and in all 4 quadrants of the IP
		if (re.test(val)) {
			//split into units with dots "."
			var parts = val.split(".");
			//if the first unit/quadrant of the IP is zero
			if (parseInt(parseFloat(parts[0])) == 0) {
				return false;
			}
			//if the fourth unit/quadrant of the IP is zero
			if (parseInt(parseFloat(parts[3])) == 0) {
				return false;
			}
			//if any part is greater than 255
			for (var i=0; i<parts.length; i++) {
				if (parseInt(parseFloat(parts[i])) > 255){
					return false;
				}
			}
			return true;
		} else {
			return false;
		}
    },
	isValidNetmask: function(val){
		val = val.replace( /\s/g, "") //remove spaces for checking
		var re = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/; //regex. check for digits and in all 4 quadrants of the IP
		if (re.test(val)) {
			var parts = val.split(".");
			//if the first unit/quadrant of the IP is zero
			if (parseInt(parseFloat(parts[0])) == 0) return false;
			//if any part is greater than 255
			for (var i=0; i<parts.length; i++) {
				if (parseInt(parseFloat(parts[i])) > 255){
					return false;
				}
			}
			return true;
		} else {
			return false;
		}
	}
  },
  
  draw : {
    boxClose : function(){
        var l = top.document.getElementById('lb_layer');
        var c = top.document.getElementById('lb_content');
        if(!l) l = document.getElementById('lb_layer');
        if(!c) c = document.getElementById('lb_content');
        if (l && l.parentNode && l.parentNode.removeChild) l.parentNode.removeChild(l);
        if (c && c.parentNode && c.parentNode.removeChild) c.parentNode.removeChild(c);
    },
    boxOpen : function(lvl, ttl, msg, w){
        
        var o = document.createElement("div");
        o.setAttribute('id','lb_layer');
        o.style.position = 'absolute';
        o.style.top = '0';
        o.style.left = '0';
        o.style.width = '100%';
        o.style.height = '100%';
        //o.style.zIndex = 1000;
        o.className = 'wui_overlay'+lvl;
        
        
        var l = document.createElement("div");
        l.setAttribute('id','lb_content');
        l.style.position = 'absolute';
        l.style.top = '0';
        l.style.left = '0';
        l.style.width = '100%';
        l.style.height = '100%';
        l.style.textAlign='center';
        //l.style.zIndex = 2000;
        l.innerHTML='<table width="100%" height="100%"><tr><td align="center"><div class="box" style="width:'+w+'px;"><h3>'+ttl+'</h3><p>'+msg+'</p></div></td></tr></table>';
        l.style.visibility = 'visible';
        if(lvl == 3)
            var b = document.getElementsByTagName("body").item(0);
        else
            var b = top.document.getElementsByTagName("body").item(0);
        b.appendChild(o);
        b.appendChild(l);
    },
    boxWait : function(ttl){
        wui.draw.boxClose();
        var t=ttl+', please wait...'
        var c='<img src="/images/wait.gif"><br><input type="button" class="bm1" name="abbort" value="Abbort" onclick="wui.draw.boxClose()">';
        wui.draw.boxOpen(2,t,c, 300);
    },
    boxInfo : function(lvl,ttl,msg){
        wui.draw.boxClose();
        var c=msg+'<br><br><input type="button" class="bm1" value="OK" onclick="wui.draw.boxClose()">';
        wui.draw.boxOpen(lvl,ttl,c,300);
    },
    boxAsk : function(lvl,ttl,msg){ //TODO
        wui.draw.boxClose();
        var c=msg+'<br><br><input type="button" class="bm1" value="Yes" onclick="wui.draw.boxClose()"> <input type="button" class="bm1" value="No" onclick="wui.draw.boxClose()">';
        wui.draw.boxOpen(lvl,ttl,c,300);
    },
    buttons : function(lvl){
        document.write('<table class="t3"><tr>');
    	document.write('<td width="33%"><a href="#" target="_self" onclick="send(\'configure\')">Save</a></td>');
    	document.write('<td width="33%"><a href="#" target="_self" onclick="send(\'restart\')">Apply</td>');
    	document.write('<td width="33%"><a href="#" target="_self" onclick="send(\'cancel\')">Cancel</a></td>');
    	document.write('</tr></table>');
    }
  }
}
