// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require jquery_ujs
//= require jquery.ui.autocomplete
//= require foundation

$(function(){ $(document).foundation(); });

var header = $('.for-venues .contain-to-grid');

// if($(window).width() < 768  ){
// 	header.addClass('sticky fixed')
// 	$('body').addClass('f-topbar-fixed');
// }else {

// }

$(function() {
   $('#notice').delay(500).fadeIn('normal', function() {
      $(this).delay(2500).fadeOut();
   });
});


$(window).resize(function(event) {
	/* Act on the event */

	// if($(window).width() < 768  ){
	// 	header.addClass('sticky fixed');
	// 	$('body').addClass('f-topbar-fixed');
	// }else{
	// 	header.removeClass('sticky fixed');
	// 	$('body').removeClass('f-topbar-fixed');
	// }
	// if($(window).width() > 768  ){
	// 	header.removeClass('sticky fixed');
	// 	$('body').removeClass('f-topbar-fixed');
	// }
});


function updateSidebar() {
    var $width = document.documentElement.clientWidth,
        $height = document.documentElement.clientHeight,
        $main = jQuery('main').height();


    if($width > 755) {
        if($main > $height) {
        	$height_set = $main + 'px';
        } else {
        	$height_set = $height + 'px';
        }
        console.log($height_set);

        jQuery('div[class=inner-wrap]').css({'height': $height_set});
    } 
}

$(window)
    .load(function() {
        updateSidebar();
    })
    .resize(function(){
        updateSidebar();
    });

function scrollHeader(){

	var homeHeader = $('.home .contain-to-grid');
	var logoImg = $('.home .home-link img');
	var logoSource = '/assets/Logo_black.png';
	var newSource = '/assets/Logo_green.png';

	var social = $('.home .ig, .home .fb, .home .tw');


	if($(window).width() >= 768  ){

		// add class on page load, swap img src
		homeHeader.addClass('transparent');
		logoImg.attr('src', newSource );
	}else{
		// homeHeader.addClass('fixed');
	}

	$(window).scroll(function(event) {
			/* Act on the event */


			if($(window).width() >= 768  ){
				var top = $(window).scrollTop();
				// console.log('top = '+top);
				if ( top > 80 ){
					homeHeader.removeClass('transparent');
					logoImg.attr('src', logoSource );
					social.removeClass('green');

				}else {
					homeHeader.addClass('transparent');
					logoImg.attr('src', newSource );
					social.addClass('green')
				}
			}

		});



	// alert(logoImg.attr('src'));
	$(window).resize(function(event) {
		/* Act on the event */
		if($(window).width() < 768  ){
			// homeHeader.addClass('sticky fixed');
			$('body').removeClass('f-topbar-fixed ');
			social.removeClass('green')
			logoImg.attr('src', logoSource );
		}else{
			logoImg.attr('src', newSource );
			social.addClass('green');
			homeHeader.addClass('transparent');
		}
	});

}

scrollHeader();

// console.log('I\'m here!');

