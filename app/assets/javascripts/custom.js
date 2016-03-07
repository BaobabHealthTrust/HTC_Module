
function loadMessage(message, location, delay){
    if (delay == null){
        delay = 1000;
    }
      if (__$('cover')){
          var ele = document.getElementById('cover');
          ele.style.display = "inline";
          document.body.appendChild(ele);

          var ele = document.getElementById('popup');
          ele.style.display = "inline";
      }else{
          var ele = document.createElement('div');
          ele.id = "cover";
          ele.style.display = "inline";
          document.body.appendChild(ele);

          var ele = document.createElement('div');
           ele.id = 'popup'
          ele.style.display = "inline";
      }
      html = "<div style='display:table;width:100%;'><div style='display:table-row;width:100%;'>";
      html += "<div id='text'>" + message + "</div></div></div>";

      html += "<div id='btn'><button class='button blue' onmousedown='reset()' style='margin: 3px; font-size: 20px; height: 55px;'>Ok</button></div>";

      ele.innerHTML =  html;
      document.body.appendChild(ele);


      setTimeout('redirect("' + location + '")', delay);
}

function redirect(location){
    window.location=location;
}

function subtractMinutes(limit, minutes, redZero){
        var sign = limit[0].match(/\-/) ? -1 : 1;
        var limitInt = (parseInt(limit[0]) * 60) + (parseInt(limit[1])* sign);
        var currentInt = (parseInt(minutes[0]) * 60) + parseInt(minutes[1]);
        var newtime = 0;

        if (limitInt || redZero) {
            newtime = (currentInt - limitInt);
            newtime = parseInt(newtime/60) + ":" + (newtime % 60);
        }
        return newtime;
}

function showListItems(target, parent, options){

        parent.innerHTML = "<ul id='listing'> </ul>"
        for (var i in options){
          var li = document.createElement("li");
          li.className = "li-item";
          li.setAttribute("tag",  (i % 2 == 0 ? "even" : "odd"));
          li.setAttribute("target", target);
          if (i % 2 == 1)
            li.style.backgroundColor = "rgb(238, 238, 238)";

          li.innerHTML = options[i];
          li.onmousedown = function(){
            highlight(this);
          }
          __$("listing").appendChild(li);
        }
      }

 function highlight(item) {

        var opts = item.parentNode.children;

        for (var i = 0; i < opts.length; i++) {
            opts[i].style.backgroundColor = (opts[i].getAttribute("tag") == "odd" ? "rgb(238, 238, 238)" : "");
        }

        __$(item.getAttribute("target")).value = item.innerHTML;
        item.style.backgroundColor = "lightblue";
        item.style.background = "lightblue !important";
        item.style.color = "black";
    }

     function reset(){
            ele = document.getElementById('cover')
            ele.style.display = "none";
            ele = document.getElementById('popup')
            ele.style.display = "none";
     }

	 function addLink(page, id){
		 path =  "/clients/" + id;
		 if (page != page.top) {     
						 if (page.top.location.href.match(/couple/g)){
								path = "/client_current_visit?client_id=" + id; 
						 }
						 else {
								path = "/clients/" + id;
							} 
					
			} 
		return path;
	}

function position(obj) {
	 var obj2 = obj;
	 var curtop = 0;
	 var curleft = 0;
	 if (document.getElementById || document.all) {
		do  {
		 curleft += obj.offsetLeft-obj.scrollLeft;
		 curtop += obj.offsetTop-obj.scrollTop;
		 obj = obj.offsetParent;
		 obj2 = obj2.parentNode;
		 while (obj2!=obj) {
			curleft -= obj2.scrollLeft;
			curtop -= obj2.scrollTop;
			obj2 = obj2.parentNode;
		 }
		} while (obj.offsetParent)
	 } else if (document.layers) {
		curtop += obj.y;
		curleft += obj.x;
	 }
	 return [curtop, curleft];
	}
