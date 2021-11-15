var evalResult = {};
var Eval = function() {

    function main() {
	loadData();
	setupButtons();
    }


    function setupButtons() {
	$('.systemUtt').on('click', function() {
	    var selectedUttId = $(this).attr('eid');
	    if (evalResult[selectedUttId] == null) {
		$(this).css('background-color', '#FF9999');
		evalResult[selectedUttId] = 1;
	    } else {
		$(this).css('background-color', '#99FFFF');
		delete evalResult[selectedUttId];
	    }
	});

	$('#sendEval').on('click', function() {
	    // alert(JSON.stringify(evalResult));
            $.ajax({
		type: 'POST',
		url: new Config().getUrl() + '/',
		async: false,
		data: JSON.stringify({
                    mode: "sendResult",
		    result: evalResult,
                    sessionid: ""}),
            }).done(function(data) {
		$('#sentStatus').text("done");
            });
	});
    };


    function loadData() {
        $.ajax({
            type: 'POST',
            url: new Config().getUrl() + '/',
            async: false,
            data: JSON.stringify({
                mode: "getDialogue",
                sessionid: ""}),
        }).done(function(data) {
	    $('#result').html(data.html);
        });
    };

    return {
	main: main
    }
}();

$(function() {
    Eval.main();
});

$(window).on('load', function() {});

