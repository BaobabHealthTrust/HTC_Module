
function loadMessage(message, location){
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
      ele.innerHTML =  html;
      document.body.appendChild(ele);

      setTimeout('redirect("' + location + '")', 1000);
}

function redirect(location){
    window.location=location;
}

function subtractMinutes(limit, minutes){

        var olddate = new Date(1982, 1, 1, limit[0], limit[1], 0, 0); 
        var newdate =  new Date(1982, 1, 1, minutes[0], minutes[1], 0, 0);
        var subbed = new Date(olddate - newdate);

        var newtime = subbed.getHours() + ':' + subbed.getMinutes();
        return newtime;
}

  function adjust(){
    var node =  document.getElementById('row2').childNodes[0].childNodes[0];
    node.style.width = "6%";
    node.style.height = "92px";
    document.getElementById('row2').childNodes[0].style.height = "92px";
    document.getElementById('row2').style.height = "92px";
    document.getElementById('row2').childNodes[0].style.backgroundColor = "grey";
    document.getElementById('row2').childNodes[0].style.MozBorderRadius = '1em';
    document.getElementById('row2').childNodes[0].style.borderRadius = '1em';
    button =  document.getElementById('buttons');
    button.style.removeProperty('border')
    button.style.backgroundColor = "grey";
  }