// https://stackoverflow.com/questions/7167085/on-append-do-something

(function($) {
    var origAppend = $.fn.append;

    $.fn.append = function () {
        return origAppend.apply(this, arguments).trigger("append");
    };
})(jQuery);

// Usage:
// $("div").bind("append", function() { alert('Something was appended!'); });
// $("div").append("<span>");