$(document).ready(function() {
    var heights = $(".panel").map(function() {
        return $(this).height();
    }).get(),

    maxHeight = Math.max.apply(null, heights);

    $(".panel").height(maxHeight);
});
