var utteranceEvalResult = {};
var Eval = function() {

    function main() {
	// loadData();
	setupButtons();
    }


    function setupButtons() {
	$('.systemUtt').on('click', function() {
	    $('#sentStatus').html("");
	    var selectedUttId = $(this).attr('eid');
	    if (utteranceEvalResult[selectedUttId] == null) {
		$(this).css('background-color', '#FF9999');
		utteranceEvalResult[selectedUttId] = 1;
	    } else {
		$(this).css('background-color', '#99FFFF');
		delete utteranceEvalResult[selectedUttId];
	    }
	    if (Object.keys(utteranceEvalResult).length > 0) {
		var content = "選択された発話ID：<input type='text' id='selectedidval' value=" + Object.keys(utteranceEvalResult).join(",") + " /><span id=copybutton>コピー</span>";
		$('#selected_ids').html(content);
		$("#copybutton").css('background', '#0776dd')

		$("#copybutton").on("click", function() {
		    $("#selectedidval").select();
		    document.execCommand('copy');
		    $("#copybutton").css('background', 'gray')
		});		

	    } else {
		$('#selected_ids').html("");
	    }
	});

	$('#inlineFormCustomSelect').on('click', function() {
	    $('#sentStatus').html("");
	});

	$('#evalId').keyup(function() {
	    $('#sentStatus').html("");
	});

	$('#sendEval').on('click', function() {
	    var evalId = $('#evalId').val();
	    var dialogEval = $('#inlineFormCustomSelect').val();

	    $('#sentStatus').html("");
            $.ajax({
		type: 'POST',
		url: new Config().getUrl() + '/',
		async: false,
		data: JSON.stringify({
                    mode: "sendResult",
		    evalId: evalId,
		    utteranceEvalResult: utteranceEvalResult,
		    dialogueEvalResult: dialogEval,
                    sessionid: ""}),
            }).done(function(data) {
		$('#sentStatus').html(data.text);
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

