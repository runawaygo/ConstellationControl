// load all the lib scripts with urlprefix where the `weibo` directory you put into 
$(function(){
	$.get('/friends',go);
	//go(data);
});

function go(data)
{
	persons = JSON.parse(data);
	initPlayer(persons);
	show(persons);
}

function initPlayer(persons)
{
	var p1 = new Player(persons[0]);
	var p2 = new Player(persons[1]);
	function display(message)
	{
		$('#resultPanel').append($('<div/>').html(message));
		// $.post('/update',{status:message},function(data, textStatus){
		// 	console.log(data);
		// });
	}
	
	PK(p1,p2,display);
}


function Player(personInfo)
{
	$.extend(this,personInfo);
	this.ability = 20;
	this.HP = 100;
}


function PK(player1,player2,callback)
{
	var flag = 0;
	var message;
	if(flag === 0)
	{
		player2.HP -= player1.ability;
		flag = 1;
		message = '@'+player2.name +' is attacked by @'+player1.name+' ' + player1.ability + ' hits HP!';
	}
	else
	{
		player1.HP -= player2.ability;
		flag = 0;
		message = '@'+player1.name +' is attacked by @'+player2.name+' ' + player2.ability + ' hits HP!';
		
		if(player1.HP <= 0) return 1;
	}
	
	callback(message);
	
	if(player2.HP <= 0) return 0;
	else if(player1.HP <= 0) return 1;
	else return -1;
	
}

 function show(persons) {
        var templateString = "";
        $("#personTemplate").tmpl(persons).appendTo("#container");

        $(".person .out-btn").hover(function () { $(this).addClass('shadow') }, function () { $(this).removeClass('shadow'); });
        $(".person .close-btn").click(
            function (event) {
                event.stopPropagation();
                $(this).closest('.person').fadeOut();
            }
        );
        $(".person .pin-btn").click(
            function () {
                event.stopPropagation();
                $(this).toggleClass('ui-icon-pin-w');
                $(this).toggleClass('ui-icon-pin-s');
            }
        );

        $(".person").find('.mid,.max').hide();
        $(".person").draggable({ start: function () { $(this).addClass('drag'); }, stop: function () { $(this).removeClass('drag'); } });
        $(".person").each(function (index) {
            $(this).css({ left: parseInt(index / 4) * 80 + 'px', top: index % 4 * 110 + 'px' });
        });
        $(".person")
        .hover(
            function () {
                $(this).addClass("pick");
            },
            function () {
                _self = $(this);
                if (_self.find('.pin-btn').hasClass('ui-icon-pin-s')) return;
                _self.find('.mid,.max').delay(800).fadeOut();
                _self.find('.min').delay(800).fadeIn();
                if (!_self.hasClass('min')) {
                    _self
                    .delay(800)
                    .animate({
                        width: '54px'
                    }, {
                        duration: 500,
                        specialEasing: {
                            width: 'swing'
                        }, complete: function () {
                        }
                    });
                }

                _self.removeClass("pick");
                _self.removeClass('mid max');
                _self.addClass('min');
            }
        );	
        $(".person").click(function () {
            var _self = $(this);
            if (_self.hasClass('min')) {
                _self.find('.min').hide();
                _self.find('.mid').fadeIn();

                _self.removeClass('min');
                _self.addClass('mid');

                _self.animate({
                    width: '400px'
                }, {
                    duration: 500,
                    specialEasing: {
                        width: 'swing'
                    }, complete: function () {
                    }
                });

            }
            else if (_self.hasClass('mid')) {
                _self.find('.max').fadeIn();

                _self.removeClass('mid');
                _self.addClass('max');
            }
        });
    }
