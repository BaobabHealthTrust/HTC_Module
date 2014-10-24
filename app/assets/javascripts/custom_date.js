function showDate(parent, target, date){
  if(parent == undefined || target == undefined){
    return;
  }  
  
  var currentdate;
  
  if(date == undefined || date == null || date.trim().length == 0){
  
    if(target.value.trim().match(/^(\d|\d{2}|\?)\/([A-Za-z]{3}|\?)\/(\d{4}|\?)$/)){
      currentdate = target.value.trim().split("/");
      
      date = new Date(currentdate[2] + "-" + padZeros((monthNames[currentdate[1]] + 1), 2) + "-" + padZeros(parseInt(currentdate[0]), 2));
    } else {
      
      date = new Date();
    }
  
  } else if(target.value.trim().match(/^(\d|\d{2}|\?)\/([A-Za-z]{3}|\?)\/(\d{4}|\?)$/)){
    currentdate = target.value.trim().split("/");
    
    date = new Date(currentdate[2] + "-" + padZeros((monthNames[currentdate[1]] + 1), 2) + "-" + padZeros(parseInt(currentdate[0]), 2));
  } else {
  
    date = new Date(date);
  
  }
  
  var tbl = document.createElement("div");
  tbl.style.display = "table";
  tbl.id = "dateTable";
  tbl.style.borderSpacing = "5px";
  
  parent.appendChild(tbl);
  
  var cells = [
      [
        {
          "type"  : "button",
          "id"    : "btnAddYearFor" + target.id,
          "target": target.id,
          "value" : "+",
          "onmousedown" : "incYear(this.getAttribute('target'))",
          "class" : "button blue",
          "style" : "height: 60px; margin: auto; width: 100%;"
        },
        {
          "type"  : "button",
          "id"    : "btnAddMonthFor" + target.id,
          "target": target.id,
          "value" : "+",
          "onmousedown" : "incMonth(this.getAttribute('target'))",
          "class" : "button blue",
          "style" : "height: 60px; margin: auto; width: 100%;"
        },
        {
          "type"  : "button",
          "id"    : "btnAddDateFor" + target.id,
          "target": target.id,
          "value" : "+",
          "onmousedown" : "incDate(this.getAttribute('target'))",
          "class" : "button blue",
          "style" : "height: 60px; margin: auto; width: 100%;"
        }
      ],
      [
        {
          "type"  : "input",
          "id"    : "txtYearFor" + target.id,
          "target": target.id,
          "value" : (!isNaN(date.getFullYear()) ? date.getFullYear() : (currentdate.length == 3 ? currentdate[2] : "?")),
          "onmousedown" : "overwriteNumber = true; if(__$('keyboard')){document.body.removeChild(__$('keyboard'));} else {showShield(\"checkiDate('\" + this.getAttribute('target') + \"', false)\"); showKeyboard(__$('txtYearFor' + this.getAttribute('target')),{':':':','/':'/','.':'.','abc':'abc'},true);} checkiDate(this.getAttribute('target'));",
          "class" : "input_cell",
          "style" : "font-size: 24px; text-align: center; width: 100%;"
        },
        {
          "type"  : "input",
          "id"    : "txtMonthFor" + target.id,
          "target": target.id,
          "value" : (typeof(months[date.getMonth()]) != "undefined" ? months[date.getMonth()] : (currentdate.length == 3 ? currentdate[1] : "?")),
          "onmousedown" : "showShield(); addList(__$('txtMonthFor' + this.getAttribute('target')),{'Jan':'January','Feb':'February','Mar':'March','Apr':'April','May':'May','Jun':'June','Jul':'July','Aug':'August','Sep':'September','Oct':'October','Nov':'November','Dec':'December','?':'Unknown'},'single',__$('txtMonthFor' + this.getAttribute('target')),__$('txtMonthFor' + this.getAttribute('target')), 'checkiDate(\"' + this.getAttribute('target') + '\")'); checkiDate(this.getAttribute('target'));",
          "class" : "input_cell",
          "style" : "font-size: 24px; text-align: center; width: 100%;"
        },
        {
          "type"  : "input",
          "id"    : "txtDateFor" + target.id,
          "target": target.id,
          "value" : (!isNaN(date.getDate()) ? date.getDate() : (currentdate.length == 3 ? currentdate[0] : "?")),
          "onmousedown" : "overwriteNumber = true; if(__$('keyboard')){document.body.removeChild(__$('keyboard'));} else {showShield(\"checkiDate('\" + this.getAttribute('target') + \"', false)\"); showKeyboard(__$('txtDateFor' + this.getAttribute('target')),{':':':','/':'/','.':'.','abc':'abc'},true);} checkiDate(this.getAttribute('target'));",
          "class" : "input_cell",
          "style" : "font-size: 24px; text-align: center; width: 100%;"
        }
      ],
      [
        {
          "type"  : "button",
          "id"    : "btnSubtractYearFor" + target.id,
          "target": target.id,
          "value" : "-",
          "onmousedown" : "decYear(this.getAttribute('target'))",
          "class" : "button blue",
          "style" : "height: 60px; margin: auto; width: 100%;"
        },
        {
          "type"  : "button",
          "id"    : "btnSubtractMonthFor" + target.id,
          "target": target.id,
          "value" : "-",
          "onmousedown" : "decMonth(this.getAttribute('target'))",
          "class" : "button blue",
          "style" : "height: 60px; margin: auto; width: 100%;"
        },
        {
          "type"  : "button",
          "id"    : "btnSubtractDateFor" + target.id,
          "target": target.id,
          "value" : "-",
          "onmousedown" : "decDate(this.getAttribute('target'))",
          "class" : "button blue",
          "style" : "height: 60px; margin: auto; width: 100%;"
        }
      ]
    ];
    
  for(var i = 0; i < cells.length; i++){
    var row = document.createElement("div");
    row.style.display = "table-row";
    
    tbl.appendChild(row);
    
    for(var j = 0; j < cells[i].length; j++){
      var cell = document.createElement("div");
      cell.style.display = "table-cell";
      cell.style.width = "140px";
      cell.style.textAlign = "center";
      
      row.appendChild(cell);
      
      var input = document.createElement("input");
      
      for(var key in cells[i][j]){
        input.setAttribute(key, cells[i][j][key]);
      }      
      
      cell.appendChild(input);
    }
  }
  
  return tbl;
}

function incYear(id){
  if(__$("txtYearFor" + id)){
    var yr = parseInt(__$("txtYearFor" + id).value.trim());
    
    yr++;
    
    __$("txtYearFor" + id).value = yr;
    
    checkiDate(id);
  }
}

function decYear(id){
  if(__$("txtYearFor" + id)){
    var yr = parseInt(__$("txtYearFor" + id).value.trim());
    
    yr--;
    
    __$("txtYearFor" + id).value = yr;
    
    checkiDate(id);
  }
}

function incMonth(id){
  if(__$("txtMonthFor" + id)){
    var month = monthNames[__$("txtMonthFor" + id).value.trim()];
    
    if(month + 1 < 12){
      month++;
    } else {
      month = 0;
    }
    
    __$("txtMonthFor" + id).value = months[month];
    
    checkiDate(id);
  }
}

function decMonth(id){
  if(__$("txtMonthFor" + id)){
    var month = monthNames[__$("txtMonthFor" + id).value.trim()];
    
    if(month - 1 >= 0){
      month--;
    } else {
      month = 11;
    }
    
    __$("txtMonthFor" + id).value = months[month];
    
    checkiDate(id);
  }
}

function incDate(id){
  if(__$("txtDateFor" + id)){
    var value = parseInt(__$("txtDateFor" + id).value.trim());
    
    var month = monthNames[__$("txtMonthFor" + id).value.trim()];
    
    if(month + 2 < 12){
      month += 2;
    } else {
      month = 1;
    }
    
    var date = new Date(__$("txtYearFor" + id).value.trim() + "-" + padZeros(month, 2) + "-01")
    
    date.setDate(date.getDate() - 1);
    
    if(value + 1 <= date.getDate()){
      value++;
    } else {
      value = 1;
    }
    
    __$("txtDateFor" + id).value = value;
    
    checkiDate(id);
  }
}

function decDate(id){
  if(__$("txtDateFor" + id)){
    var value = parseInt(__$("txtDateFor" + id).value.trim());
    
    var month = monthNames[__$("txtMonthFor" + id).value.trim()];
    
    if(month + 2 < 12){
      month += 2;
    } else {
      month = 1;
    }
    
    var date = new Date(__$("txtYearFor" + id).value.trim() + "-" + padZeros(month, 2) + "-01")
    
    date.setDate(date.getDate() - 1);
    
    if(value - 1 > 0){
      value--;
    } else {
      value = date.getDate();
    }
    
    __$("txtDateFor" + id).value = value;
    
    checkiDate(id);
  }
}

function checkiDate(id, byAge){
  
	if(__$("txtDateFor" + id) && __$("txtYearFor" + id) && __$("txtMonthFor" + id)){
	  
		if(byAge == undefined || byAge == false){
		
			if(!__$("txtYearFor" + id).value.trim().match(/^\d{4}$/)){
		  
				__$("txtYearFor" + id).value = "?";

				__$("txtMonthFor" + id).value = "?";

				__$("txtDateFor" + id).value = "?";
						  
				if(__$(id)){
				  
				  __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();
				  
				}

				if(__$("age" + id)){
					
				  __$("age" + id).value = "";

				}
				
				return;
				
			}
		
			if(__$("txtMonthFor" + id).value.trim() == "?"){
			
				__$("txtMonthFor" + id).value = "?";
				
				__$("txtDateFor" + id).value = "?";
						  
				if(__$(id)){
				  
				  __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();
				  
				}

				if(__$("age" + id)){
				  
				  var actual = __$("txtYearFor" + id).value.trim() + "-" + padZeros((new Date()).getMonth() + 1, 2) + "-" + padZeros((new Date()).getDate(), 2);
				  
				  var age = ((new Date()) - (new Date(actual))) / (365 * 24 * 60 * 60 * 1000);
						  
				  __$("age" + id).value = Math.round(age);
				
				}
				
				return;
			
			}
		
			if(__$("txtDateFor" + id).value.trim() == "?"){
				
				__$("txtDateFor" + id).value = "?";
				  
				if(__$(id)){
				  
				  __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();
				  
				}
			  
				if(__$("age" + id)){
				  
				  var actual = __$("txtYearFor" + id).value.trim() + "-" + padZeros((new Date()).getMonth() + 1, 2) + "-" + padZeros((new Date()).getDate(), 2);
				  
				  var age = ((new Date()) - (new Date(actual))) / (365 * 24 * 60 * 60 * 1000);
						  
				  __$("age" + id).value = Math.round(age);
				
				}
				
				return;
				
			}
		  
			var value = parseInt(__$("txtDateFor" + id).value.trim());

			var month = monthNames[__$("txtMonthFor" + id).value.trim()];

			if(month + 1 < 12){
				month += 2;
			} else {
				month = 1;
			}

			var date = new Date(__$("txtYearFor" + id).value.trim() + "-" + padZeros(month, 2) + "-01")

			date.setDate(date.getDate() - 1);

			if(value > date.getDate()){
				value = date.getDate();
			}

			__$("txtDateFor" + id).value = value;

			if(__$(id)){

				__$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

			}
		  
			if(__$("age" + id)){

				var actual = __$("txtYearFor" + id).value.trim() + "-" + padZeros((month - 1 < 1 ? 12 : (month - 1)), 2) + "-" + padZeros(parseInt(__$("txtDateFor" + id).value.trim()), 2);

				var age = ((new Date()) - (new Date(actual))) / (365 * 24 * 60 * 60 * 1000);
						
				__$("age" + id).value = Math.round(age);

			}

		} else {
    
			if(__$("age" + id)){
        
				var age = parseInt(__$("age" + id).value);
				
				if(!isNaN(age)){
				  
				  var yrs = (new Date()).getFullYear() - age;
				  
				  __$("txtYearFor" + id).value = yrs;
				  
				  __$("txtMonthFor" + id).value = "?";
				  
				  __$("txtDateFor" + id).value = "?";
				  
				} else {
					
				  __$("txtYearFor" + id).value = "?";
				  
				  __$("txtMonthFor" + id).value = "?";
				  
				  __$("txtDateFor" + id).value = "?";
						   
				}
			}
       
			if(__$(id)){
				
				if(!__$("txtYearFor" + id).value.trim().match(/^\d{4}$/)){
      
					__$("txtYearFor" + id).value = "?";

					__$("txtMonthFor" + id).value = "?";

					__$("txtDateFor" + id).value = "?";
							  
					if(__$(id)){
					  
					  __$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();
					  
					}

					if(__$("age" + id)){
						
					  __$("age" + id).value = "";

					}
					
					return;
					
				}
    
				if(__$("txtMonthFor" + id).value.trim() == "?"){
        
					__$("txtMonthFor" + id).value = "?";
					
					__$("txtDateFor" + id).value = "?";
							  
					if(__$(id)){
					  
						__$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();
					  
					}

					if(__$("age" + id)){
					  
						var actual = __$("txtYearFor" + id).value.trim() + "-" + padZeros((new Date()).getMonth() + 1, 2) + "-" + padZeros((new Date()).getDate(), 2);

						var age = ((new Date()) - (new Date(actual))) / (365 * 24 * 60 * 60 * 1000);
							  
						__$("age" + id).value = Math.round(age);
					
					}
					
					return;
				
				}
        
				if(__$("txtDateFor" + id).value.trim() == "?"){
				
					__$("txtDateFor" + id).value = "?";
				  
					if(__$(id)){
				  
						__$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();
				  
					}
				  
					if(__$("age" + id)){
					  
					  var actual = __$("txtYearFor" + id).value.trim() + "-" + padZeros((new Date()).getMonth() + 1, 2) + "-" + padZeros((new Date()).getDate(), 2);
					  
					  var age = ((new Date()) - (new Date(actual))) / (365 * 24 * 60 * 60 * 1000);
							  
					  __$("age" + id).value = Math.round(age);
					
					}
					
					return;
				
				}
		  
				var value = parseInt(__$("txtDateFor" + id).value.trim());

				var month = monthNames[__$("txtMonthFor" + id).value.trim()];

				if(month + 1 < 12){
					month += 2;
				} else {
					month = 1;
				}

				var date = new Date(__$("txtYearFor" + id).value.trim() + "-" + padZeros(month, 2) + "-01")

				date.setDate(date.getDate() - 1);

				if(value > date.getDate()){
					value = date.getDate();
				}

				__$("txtDateFor" + id).value = value;

				if(__$(id)){

					__$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();

				}
		  
				__$(id).value = __$("txtDateFor" + id).value.trim() + "/" + __$("txtMonthFor" + id).value.trim() + "/" + __$("txtYearFor" + id).value.trim();
        
			}
              
		}
	}
}
