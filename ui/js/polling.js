var Eval = function() {

    function sleep(msec) {
	return new Promise(function(resolve) {
	    setTimeout(function() {resolve()}, msec);
	})
    }

    async function main() {
	while (true) {
	    loadData();
	    await sleep(5100);
	    var msec = new Date()
	    $('#note').text(msec);
	}
    }

    function loadData() {
        $.ajax({
            type: 'POST',
            url: new Config().getUrl() + '/',
            async: false,
            data: JSON.stringify({
                input: "inputText",
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
