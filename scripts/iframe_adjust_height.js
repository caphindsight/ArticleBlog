$( function () {
    $("iframe.adjust-height").each(function (i, e) {
        var $e = $(e);
        
        function resize() {
            var h = $e.contents().find("body").height() + 50;
            if ($e.height() != h) {
                $e.height(h);
            }
        };

        $e.load(resize);
        $e.resize(resize);

        window.setInterval(resize, 1000);
    });
} );

