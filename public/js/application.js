$(document).ready(function() {
    $(".created_at").timeago();
    $("#add-post").dialog({
        autoOpen: false,
        title: "JSF Sucks 4 me because ....",
        width: '400',
        height: '270',
        buttons: {
            "Cancel": function() {
                $("#post-clear").click();
                $(this).dialog("close");
            },
            "Share with the class": function() {
                $("#posts").html("<div class='wait-panel'></div>");
                $.post("/complain", $("#post").serialize(), function(data) {
                    $("#post-clear").click();
                    $("#posts").load("/list", function() {
                        $(".created_at").timeago();
                    });
                    $('#add-post').dialog("close");
                });
            }
        }
    });
    $("#link-to-post").click(function(e) {
        e.preventDefault();
        $("#add-post").dialog("open");
    });
});
