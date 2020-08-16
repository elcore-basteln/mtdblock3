var opt = {
    width: 720,
    height: 420,
    color:{
        canvas:"#041C3B",
        box:"#052652",
        axe:"#FFFFFF",
        grid:"#CCCCCC",
        /* x color of x axe labeling */
        x:"#CCCCCC",
        /* y[0] first graphline color
           y[1] second graphline color
           y[2] color of limit lines
           y[3] color of on/off lines
        */
        y:["#FFFF00","#00FF00","#FF0000","#FFFFFF"],
        /* z[0] color of first alarm row
           z[1] color of second alarm row
           z[2] color of third alarm row
           z[3] color of fourth alarm row
        */
        z:["#FF3300","#FF3300","#FF3300","#FF3300"]
    },
    box1: [60,20,600,300],        /*array: [left offset, top offset, width, height] */
    box2: [60,348,600,48],         /*array: [left offset, top offset, width, height] */
    canvas: null
};
function get_color(obj)
{
    if(obj.currentStyle)
        return obj.currentStyle.color;
    if(document.defaultView)
        return document.defaultView.getComputedStyle(obj, null).getPropertyValue("color");
    return "#000000";
}

function graph_init()
{
    var o = document.getElementById('graph');
    opt.color.canvas = get_color(document.getElementById("eGbg"));
    opt.color.box = get_color(document.getElementById("eGbox"));
    
    //excanvas hack
    if (window.G_vmlCanvasManager && window.attachEvent && !window.opera)
        o = window.G_vmlCanvasManager.initElement(o);

    opt.canvas = o.getContext('2d');
    opt.canvas.textBaseline = "top";
    graph_draw_bg(opt.canvas);
}

function graph_draw(data)
{
    opt.canvas.clearRect(0, 0, opt.width, opt.height);
    labels_remove();
    graph_draw_bg(opt.canvas);
    graph_draw_grid(opt.canvas, data);
    graph_draw_series(opt.canvas, data);
}

function graph_draw_bg(c)
{
    var g1=opt.box1;      /*array: [left offset, top offset, width, height] */
    var g2=opt.box2;      /*array: [left offset, top offset, width, height] */
    
    c.save();
    c.fillStyle = opt.color.canvas;
    c.fillRect(0, 0, opt.width, opt.height);
    c.fillStyle = opt.color.box;
    c.fillRect(g1[0], g1[1], g1[2], g1[3]);
    c.fillRect(g2[0], g2[1], g2[2], g2[3]);
    c.restore();
}

function graph_draw_grid(c, data)
{
    c.save();
    
    drawGridX(c, data.grid.x);
    drawGridY(c, data.grid.y);
    drawGridZ(c, data.grid.z);
    
    /* draw comment at the bottom at graph */
    drawLabel(data.comment[0], 5, opt.height-15, "bold 12px DejaVu Sans", opt.color.axe);
    drawLabel(data.comment[1], opt.width/2-(data.comment[1].length*8), opt.height-15, "bold 12px DejaVu Sans", opt.color.axe);
    drawLabel(data.comment[2], opt.width-(data.comment[2].length*8), opt.height-15, "bold 12px DejaVu Sans", opt.color.axe);
    c.fill();

    c.restore();
}

function graph_draw_series(c, data)
{
    c.save();
    switch (data.type) {
    case 1:
        drawLineGraph(c, data.data.x, data.data.y[0], opt.color.y[0], true);
        drawLineGraph(c, data.data.x, data.data.y[1], opt.color.y[2], false);
        drawLineGraph(c, data.data.x, data.data.y[2], opt.color.y[2], false);
        drawLineAlert(c, data.data.x, 1, data.data.z, data.grid.z[1][0]);
        drawLineAlert(c, data.data.x, 2, data.data.z, data.grid.z[2][0]);
        drawLineAlert(c, data.data.x, 3, data.data.z, data.grid.z[3][0]);
        break;
    case 2:
        drawLineGraph(c, data.data.x, data.data.y[0], opt.color.y[0], true);
        drawLineGraph(c, data.data.x, data.data.y[1], opt.color.y[1], true);
        
        break;
    }
    drawLineAlert(c, data.data.x, 0, data.data.z, data.grid.z[0][0]);
    drawLineOnOff(c, data.data.x, data.data.y[0], opt.color.y[3]);
    c.restore();
}




/*  Draw graph line
    c = canvas object
    x = x axe coordinates in pixel, array
    y = y axe coordinates in pixel, array
    d = dye, line color
*/
function drawLineGraph(c, x, y, d, s){
    var g1=opt.box1;      /*array: [left offset, top offset, width, height] */
    var g2=opt.box2;      /*array: [left offset, top offset, width, height] */
    var off = true;
    
    c.strokeStyle = d;
    c.lineCap = "round";
    c.lineWidth = 3;
    c.beginPath();
    c.lineJoin = "round";
    
    /* setup graph schadow */
    if (s) {
        c.shadowColor = "#000000";
        c.shadowOffsetX = 3;
        c.shadowOffsetY = 3;
        c.shadowBlur = 10;
        c.lineWidth = 5;
    }
    for(var i=0; i<x.length; i++) {
        if(typeof y[i] != 'number') {
            off = true;
            continue;
        } 
        if(off) {
            c.moveTo(g1[0]+x[i],      g1[1]+g1[3]-y[i]);
            off = false;
        }
        c.lineTo(g1[0]+x[i],   g1[1]+g1[3]-y[i]);
    }
    c.stroke();
    
    /* remove graph schadow settings */
    if (s) {
        c.shadowOffsetX = 0;
        c.shadowOffsetY = 0;
        c.shadowBlur = 0;
        c.lineWidth = 3;
    }
}

/*  Draw OnOff lines
    c = canvas object
    x = x axe coordinate in pixel
    d = dye, line color
*/
function drawLineOnOff(c, x, y, d){
    var g1=opt.box1;      /*array: [left offset, top offset, width, height] */
    var g2=opt.box2;      /*array: [left offset, top offset, width, height] */
    var off = false;
    var l = 0;
    
    c.strokeStyle = d;
    c.lineCap = "round";
    c.lineWidth = 3;
    c.beginPath();
    
    for (var i=0; i<x.length; i++) {
        if (i > 0) l=1;
        if (!off && typeof y[i] != 'number') {
            c.moveTo(g1[0]+x[i-l],      g1[1]-3);
            c.lineTo(g1[0]+x[i-l],      g1[1]+g1[3]+3);
            off = true;
        } else if(off && typeof y[i] == 'number') {
            c.moveTo(g1[0]+x[i-l],      g1[1]-3);
            c.lineTo(g1[0]+x[i-l],      g1[1]+g1[3]+3);
            off = false;
        }
    }
    c.stroke();
}

/*  Draw data of alarm status graph
    c = canvas object
    x = x axe coordinate in pixel
    y = y axe line coordinate (0 1 2 or 3). 0 is first line from top;
    z = alarms state value
    m = alarm mask
*/
function drawLineAlert(c, x, y, z, m){
    var g1=opt.box1;      /*array: [left offset, top offset, width, height] */
    var g2=opt.box2;      /*array: [left offset, top offset, width, height] */
    var ln = 6;
    
    c.strokeStyle = opt.color.z[y];
    c.lineCap = "butt";
    c.lineWidth = 10;
    if (x.length > 1)
        ln = x[1]-x[0]+1;
    
    for (var i=0; i<x.length; i++) {
        if (typeof z[i] != 'number') {
            continue;
        }
        if(z[i] & m) {
            c.beginPath();
            c.moveTo(g2[0]+x[i],      g2[1]+6+12*y);
            if(x[i]+ln > g2[2])
                ln = g2[2]-x[i];
            c.lineTo(g2[0]+x[i]+ln,    g2[1]+6+12*y);
            c.stroke();
        }
    }
}

/* Draw X grid and labels
    c = canvas object
    l = array with labels and X coordinates in pixel [Xpx, "label").
*/
function drawGridX(c, l) {
    var g1=opt.box1;      /*array: [left offset, top offset, width, height] */
    var g2=opt.box2;      /*array: [left offset, top offset, width, height] */

    /* draw x grid and labels */
    c.strokeStyle = opt.color.grid;
    c.lineWidth = 1;
    c.beginPath();
    for(var i=0; i<l.length; i++) {
        c.moveTo(g1[0]+l[i][0], g1[1]);              //graph 1
        c.lineTo(g1[0]+l[i][0], g1[1]+g1[3]+5);      //graph 1
        c.moveTo(g1[0]+l[i][0], g2[1]-3);            //graph 2
        c.lineTo(g1[0]+l[i][0], g2[1]+g2[3]+3);      //graph 2
        drawLabel(l[i][1], g1[0]+l[i][0]-(l[i][1].length*8)/2, g1[1]+g1[3]+10, "bold 12px DejaVu Sans", opt.color.grid);
    }
    c.stroke();
    
    /* x axe */
    c.strokeStyle = opt.color.axe;
    c.lineCap = "round";
    c.lineWidth = 3;
    c.beginPath();
    c.moveTo(g1[0],        g1[1]+g1[3]);
    c.lineTo(g1[0]+g1[2],  g1[1]+g1[3]);
    c.stroke();
}

/* Draw Y grid and labels
    c = canvas object
    l = array with labels and Y coordinates in pixel [Ypx, "label left", "label right").
*/
function drawGridY(c, l) {
    var g1=opt.box1;          /*array: [left offset, top offset, width, height] */
    var g2=opt.box2;          /*array: [left offset, top offset, width, height] */
    
    if (l.length == 0)
        return;
    
    /* draw y grid and labels */
    c.strokeStyle = opt.color.grid;
    c.lineWidth = 1;
    c.beginPath();
    for(var i=0; i<l.length-1; i++) {
        c.moveTo(g1[0]-5,       g1[3]+g1[1]-l[i][0]);
        c.lineTo(g1[0]+g1[2]+5, g1[3]+g1[1]-l[i][0]);
        drawLabel(l[i][1], 10, g1[3]+g1[1]-l[i][0]-6, "bold 12px DejaVu Sans", opt.color.grid);
        drawLabel(l[i][2], g1[0]+g1[2]+10, g1[3]+g1[1]-l[i][0]-6, "bold 12px DejaVu Sans", opt.color.grid);
    }
    c.moveTo(g1[0]-5,       g1[3]+g1[1]-l[i][0]);
    c.lineTo(g1[0]+g1[2]+5, g1[3]+g1[1]-l[i][0]);
    drawLabel(l[i][1], 10, g1[3]+g1[1]-l[i][0]-10, "bold 18px DejaVu Sans", opt.color.y[0]);
    drawLabel(l[i][2], g1[0]+g1[2]+10, g1[3]+g1[1]-l[i][0]-10, "bold 18px DejaVu Sans", opt.color.y[1]);
    c.stroke();
    
    c.strokeStyle = opt.color.axe;
    c.lineCap = "round";
    c.lineWidth = 3;
    c.beginPath();
    /* vertical first y axe */
    c.moveTo(g1[0],        g1[1]);
    c.lineTo(g1[0],        g1[1]+g1[3]);
    if (l[0][2] && l[0][2] != "") {
        /* vertical second y axe */
        c.moveTo(g1[0]+g1[2],  g1[1]);
        c.lineTo(g1[0]+g1[2],  g1[1]+g1[3]);
    }
    c.stroke();
}

/* Draw Y grid and labels
    c = canvas object
    l = array with labels and mask [mask, "label left", "label right").
*/
function drawGridZ(c, l) {
    var g1=opt.box1;          /*array: [left offset, top offset, width, height] */
    var g2=opt.box2;          /*array: [left offset, top offset, width, height] */
    
    /* configure drawing */
    c.strokeStyle = opt.color.grid;
    c.lineWidth = 1;
    c.beginPath();
    
    /* draw labels */
    for (var i=0; i<l.length; i++) {
        c.moveTo(g2[0]-5,                  g2[1]+12*i);
        c.lineTo(g2[0]+g2[2]+5,            g2[1]+12*i);
        drawLabel(l[i][1], 10,             g2[1]+12*i, "11px DejaVu Sans", opt.color.grid);
        drawLabel(l[i][2], g2[0]+g2[2]+10, g2[1]+12*i, "11px DejaVu Sans", opt.color.grid);
    }
    c.moveTo(g2[0]-5,                    g2[1]+12*i);
    c.lineTo(g2[0]+g2[2]+5,              g2[1]+12*i);
    c.stroke();
}

function drawLabel(t, x, y, f, c)
{
    if(opt.canvas.fillText) {
        opt.canvas.fillStyle = c;
        opt.canvas.font = f;
        opt.canvas.fillText(t, x, y);
        return 0;
    }
    
    var objBody = document.getElementById("eTgrf");
    var objOverlay = document.createElement("div");
    objOverlay.style.position = 'absolute';
    objOverlay.style.top = y+'px';
    objOverlay.style.height = '20px';
    objOverlay.style.left = x+'px';
    objOverlay.style.font = f;
    objOverlay.style.color = c;
    objBody.appendChild(objOverlay);
    objOverlay.innerHTML = t;
}

function labels_remove() {
    var objBody = document.getElementById("eTgrf");
    for(var i = 0; objBody.childNodes[i]; i++) {
        if(objBody.childNodes[i].nodeName.toLowerCase() == "div") {
            objBody.removeChild(objBody.childNodes[i--]);
        }
    }
}