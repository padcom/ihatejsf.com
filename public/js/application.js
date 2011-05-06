$(document).ready(function() {
    $("#add-post").dialog({
        autoOpen: false,
        title: "JSF Sucks 4 me because ....",
        width: '400',
        height: '140',
        buttons: {
            "Cancel": function() {
                $("#post-clear").click();
                $(this).dialog("close");
            },
            "Share with the class": function() {
                $("#posts").html("<div class='wait-panel'></div>");
                $.post("/complain", $("#post").serialize(), function(data) {
                    $("#post-clear").click();
                    $("#posts").load("/list");
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
