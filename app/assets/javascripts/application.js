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
//= require jquery
//= require jquery_ujs
//= require jquery.ui.autocomplete
//= require foundation

$(function(){ $(document).foundation(); });

var header = $('.for-venues .contain-to-grid');

if($(window).width() < 768  ){
	header.addClass('sticky fixed')
	$('body').addClass('f-topbar-fixed');
}else {

}


$(window).resize(function(event) {
	/* Act on the event */

	if($(window).width() < 768  ){
		header.addClass('sticky fixed');
		$('body').addClass('f-topbar-fixed');
	}else{
		header.removeClass('sticky fixed');
		$('body').removeClass('f-topbar-fixed');
	}
});

function scrollHeader(){

	var homeHeader = $('.home .contain-to-grid');
	var logoImg = $('.home .home-link img');
	var logoSource = '/assets/yero-black-vector.svg';
	var newSource = '/assets/yero-green-vector.svg';

	var social = $('.home .ig, .home .fb, .home .tw');


	if($(window).width() > 768  ){

		// add class on page load, swap img src
		homeHeader.addClass('transparent');
		logoImg.attr('src', newSource );
	}else{
		homeHeader.addClass('fixed');
	}

	$(window).scroll(function(event) {
			/* Act on the event */


			if($(window).width() > 768  ){
				var top = $(window).scrollTop();
				// console.log('top = '+top);
				if ( top > 150 ){
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
			homeHeader.addClass('sticky fixed');
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

