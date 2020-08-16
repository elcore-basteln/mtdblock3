var doc=document.form;
var suchen=0;
var suchcounter=0;
hide();

function hide(){
	if(!document.getElementById)return;

	d=document.getElementsByTagName('tr');
	if (doc.CHK$openvpn.checked){
		if(doc.RAD$auswahl[0].checked && doc.CMB$authby.value=="authby-pkcs12")
			doc.CMB$authby.value="authby-certs";
		versteck=doc.RAD$auswahl[0].checked?'client':'server';
		switch(doc.CMB$authby.value){
			case "authby-shared": versteck2='certs'; versteck3='pkcs'; break;
			case "authby-certs": versteck2='shared'; versteck3='pkcs'; break;
			case "authby-pkcs12": versteck2='shared'; versteck3='certs'; break;
		}
		for(var i=0;i<d.length;i++) {
			var s=d[i].className.split('-');
			if(s[0]==versteck||s[1]==versteck2||s[1]==versteck3)
				d[i].style.display="none";
			else
				d[i].style.display="";
		}
		
		if(doc.RAD$auswahl[0].checked){
			//server
			document.getElementById('autbypkcs12').style.display="none";
			if(doc.CMB$authby.value=="authby-shared"){
				//Server shared keys
				if(document.getElementsByName('TXT$sharedexist')[0].value=="")
					document.getElementById('sharedkey').style.display="none";
			}else{
				//Server Certs
				if(doc.CMB$clientmode.value=="clientmodebridge"){
					//Server bridge
					document.getElementById('cnet').style.display="none";
					if(!doc.CHK$dgw.checked)
						document.getElementById('gwip').style.display="none";
				}else{
					//Server Roadwarrior
					document.getElementById('sbrip').style.display="none";
					document.getElementById('startip').style.display="none";
					document.getElementById('endip').style.display="none";
					document.getElementById('gwon').style.display="none";
					document.getElementById('gwip').style.display="none";
				}
				if(doc.TXT$rcaexist.value=="")
					document.getElementById('rootca').style.display="none";
				//keys
				for(var i=1;i<=8;i++){
					if(document.getElementsByName('TXT$client'+i+'exist')[0].value=="")
						document.getElementById('client'+i).style.display="none";
				}
			}
		}else{
			//client
			document.getElementById('autbypkcs12').style.display="";
			document.getElementById('adrhelp').innerHTML=doc.CHK$aws3.checked?"&nbsp;AWS Bucket name":"&nbsp;IP address or DNS name";
			if(doc.CMB$cclientmode.value=="cclientmoderw")
				document.getElementById('cbrip').style.display="none";
			if (!doc.CHK$fwenab.checked)
				document.getElementById('fwurl').style.display="none";
		}
		//Server|Client shared keys
		if(doc.CMB$authby.value=="authby-shared"){
			document.getElementById('sip1').style.display="";
			document.getElementById('subn').style.display="";
		}
	}else{
		//disabled
		for(var i=0;i<d.length;i++){
			var s=d[i].className.split('-');
			d[i].style.display=(d[i].className=='main'||s[0]=='client'||s[0]=='server')?"none":"";
		}
	}
}

//--------------------------------------- sendefunction -------------------------------------------
function send(command){
	if(command=="cancel"){doc.reset();return 0;}

	if(!test_inrange(doc.TXT$serverport,1,65535)){
		if(doc.RAD$auswahl[0].checked){		//server mode
			alert ("Error ! Value must be within 1 - 65535 !");
			return;
		}else{
			doc.TXT$serverport.value = "";
		}
	}
	if(!test_inrange(doc.TXT$port,1,65535)){
		if(doc.RAD$auswahl[1].checked){		//client mode
			alert ("Error ! Value must be within 1 - 65535 !");
			return;
		}else{
			doc.TXT$port.value = "";
		}
	}
	if(doc.RAD$auswahl[0].checked){
		// Server
		if(doc.CMB$clientmode.value=="clientmodebridge"){
			// Server-Bridged
			if(!test_ip('TXT$ovpnethip',true,"Bridge IP")) return;
			if(!test_ip('TXT$ovpneth1ip',true,"Start IP")) return;
			if(!test_ip('TXT$ovpneth2ip',true,"End IP")) return;
			if(doc.CHK$dgw.checked)
				if(!test_ip('TXT$dgate',true,"Gateway IP")) return;
		}else{
			// Server-Roadwarrior
			if(!test_ip('TXT$ovpnethnet',true,"Network")) return;
		}
		if(!test_ip('TXT$ovpnethsub',true,"Netmask")) return;
	}else{
		if(doc.TXT$address.value==""){
			alert ("Error! Please enter a server address!");
			return;
		}
	}
	if(doc.CMB$authby.value=="authby-shared"){
		if(!test_ip('TXT$shared1ip',true,"This side IP")) return;
		if(!test_ip('TXT$ovpnethsub',true,"Netmask")) return;
		//if(!test_ip('TXT$shared2ip',true,"Other side IP")) return;
	}
	if(!doc.RAD$dev[0].checked && !doc.RAD$dev[1].checked){
		alert ("Error ! Please select TUN or TAP as device !");
		return;
	}

	doc.TXT$submit.value=command;
	doc.submit();
}

function show(what){
	window.open('/cgi-bin/openvpn_cfg.cgi?' + what,'Clientinfos',
		'toolbar=no,'+
		'location=no,'+
		'directories=no,'+
		'status=no,'+
		'menubar=no,'+
		'scrollbars=yes,'+
		'resizable=yes,'+
		'width=640,'+
		'height=480');
}

function createnow(command){
	var conf = false;
	if(command == "serverkeys"){
		conf = confirm("You are about to create new serverkeys. Old keys will be deleted. It takes some time to create new keys. Press Ok to confirm action.");
	}else{
		conf = confirm("You are about to create new clientkey(s). Old key(s) will be deleted. New keys will match the current server keys ! Press Ok to confirm action.");
	}

	info_id=command=="sharedkey"?"create_info_shared":"create_info";
	info_element=document.getElementById(info_id);
	if ( conf == true ){
		suchen=1;search("Creating : ",info_id,1800,"Timeout");
		doc.serverkeysb.disabled=true;
		
		var http_request = false;
		if (window.XMLHttpRequest) { // Mozilla, Safari,...
			http_request = new XMLHttpRequest();
		} else if (window.ActiveXObject) { // IE
			try {
				http_request = new ActiveXObject("Msxml2.XMLHTTP");
			} catch (e) {
				try {
					http_request = new ActiveXObject("Microsoft.XMLHTTP");
				} catch (e) {}
			}
		}
		if (http_request){
			http_request.onreadystatechange = function(){
				if (http_request.readyState == 4) {
					if (http_request.status == 200) {
						if(http_request.responseText.charAt(0)=='<'){
							top.location.href=("/cgi-bin/login.cgi");
						}else{
							suchen=0;suchcounter=0;
							if(http_request.responseText.charAt(0)=='F'){
								info_element.innerHTML = '&nbsp;' + http_request.responseText;
							}else{
								info_element.innerHTML = '&nbsp;' + 'Success';
							}
							doc.serverkeysb.disabled=false;
						}
					} else {
						//fehler
						suchen=0;suchcounter=0;
						info_element.innerHTML = '&nbsp;' + 'Connection lost';
					}
				}
			};
			http_request.open('GET', '/cgi-bin/openvpn_cfg.cgi?'+command, true);
			http_request.send(null);	
		}else{
			alert('No XMLHTTP ActiveXObject could be created !');
		}
	}
}

function search(string1,feld,countout,string2){
	if(suchen!=0){
		if(suchen.length>50 || suchen==1) suchen=string1;
		suchcounter++;
		if((suchcounter/3) >= countout){ 
			suchen=0; suchcounter=0;
			document.getElementById(feld).innerHTML='&nbsp;'+string2;
			doc.syncnowb.disabled=false;
			return 0;
		}
		suchen=suchen + ' |';
		document.getElementById(feld).innerHTML='&nbsp;' + suchen;
		setTimeout('search("'+string1+'","'+feld+'",'+countout+',"'+string2+'")',333);
	}
}
