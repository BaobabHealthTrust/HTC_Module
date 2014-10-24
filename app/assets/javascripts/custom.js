
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
