var Eval = function() {
    var result = "";
    
    function main() {
	loadData();
    }

    function loadData() {
	var result = "";
        $.ajax({
            type: 'POST',
            url: new Config().getUrl() + '/',
            async: false,
            data: JSON.stringify({
                input: "inputText",
                sessionid: ""}),
        }).done(function(data) {
	    result += data.html;
	    $('#result').html(result);
        });
    }

    return {
	main: main
    }
}();

$(function() {
    Eval.main();
});

$(window).on('load', function() {});
