jQuery(document).ready(function($) {
	 jQuery(".cityAjax").autocomplete({
		source: function (request, response) {
		 jQuery.getJSON(
			"http://gd.geobytes.com/AutoCompleteCity?callback=?&q="+request.term,
			function (data) {
			 response(data);
			}
		 );
		},
		minLength: 3,
		select: function (event, ui) {
		 var selectedObj = ui.item;
		 jQuery(".cityAjax").val(selectedObj.value);
		 return false;
		},
		open: function () {
		 jQuery(this).removeClass("ui-corner-all").addClass("ui-corner-top");

		},
		close: function () {
		 jQuery(this).removeClass("ui-corner-top").addClass("ui-corner-all");
 
		}
	 });
	 jQuery(".cityAjax").autocomplete("option", "delay", 100);
     if(jQuery('ul.ui-autocomplete').length){
        jQuery('ul.ui-autocomplete').addClass('dropdown-menu');
     }
	});