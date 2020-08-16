
function hidetabs(von,bis,zeige){
    for(var j=von; j<=bis ; j++)	
	try{document.getElementById('line' + j).style.display = zeige;}catch(e){}
}

function test_ip(label,fillall,name){
	var p=4;
	for (var i=1;i<5;i++){
		feld=document.form.elements[(label+i)];
		if(test_inrange(feld,0,255)){
			feld.value*=1;
			p++;
		}else if(feld.value!=""){
			alert ("Error ! Possible values between 0 - 255 ! ("+name+")");
			return false;
		}else{
			p--;
		}
	}
	if(p==8 || (p==0 && !fillall)) return true;
	alert(" Error ! All fields need to be empty or filled ("+name+")!");
	return false;
}

function autofillv(ip,to,ls){
	feld=doc.elements[ls];
	if(feld.value!="") return;
	toport=doc.elements[to].value;
	if(toport>999) return;
	toip=doc.elements[ip].value;
	if(toip<=99) value=100*toport+1*toip;
	else if(toport<=99) value=100*toip+1*toport;
	else return;
	if(value<100 || value>65500 || 1*toport==1*value) return;
	feld.value=value;
}

function autofill(){
	autofillv('TXT$toip4','TXT$toport','TXT$fromport');
}

function test_int(feld){
	feld.value=trim(feld.value);
	if(feld.value=="") return false;
	for (var i=0; i < feld.value.length; ++i){
		if (feld.value.charAt(i) < "0" || feld.value.charAt(i) > "9") return false;
	}
	return true;
}

function trim(str){
	var str1=str;
	for (i = 0; i < str.length; i++)
		str1=str1.replace(/ /, "");
	return str1;
}

function test_inrange(feld,min,max){
	if(test_int(feld))
		if(feld.value>=min && feld.value<=max)
			return true;
	return false;
}

function access(info){
	if (info != "x"){
	document.write('<table border="1" width="255" cellspacing="0" align="right"><tr class="seitenfuss">');
	document.write('<td width="33%"><p><a href="#" target="_self" onclick="send('+"'ok'"+')">Save</a></p></td>');
	document.write('<td width="33%"><p><a href="#" target="_self" onclick="send('+"'apply'"+')">Apply</a></td>');
	document.write('<td width="33%"><p><a href="#" target="_self" onclick="send('+"'cancel'"+')">Cancel</a></p></td>');
	document.write('</tr></table>');
	}
}

function access_old(info){
	if (info != "x"){
	document.write('<tr><td valign="bottom" colspan="3" height="20" align="right">');
	document.write('<table border="1" width="255" cellspacing="0"><tr class="seitenfuss">');
	document.write('<td width="33%"><p><a href="#" target="_self" onclick="send('+"'ok'"+')">Save</a></p></td>');
	document.write('<td width="33%"><p><a href="#" target="_self" onclick="send('+"'apply'"+')">Apply</a></td>');
	document.write('<td width="33%"><p><a href="#" target="_self" onclick="send('+"'cancel'"+')">Cancel</a></p></td>');
	document.write('</tr></table></td></tr>');
	}
}
