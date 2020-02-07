$(document).ready(function () {
    $("#quizForm").submit(function (event) {
        // Disable automatic processing of the form
        event.preventDefault();
        // Manipulate html objects before form processing
        $("#submitBtn").addClass("d-none");
        $("#hintSection").removeClass("d-block");
        $("#hintSection").addClass("d-none");
        $("#question").html("Loading ...");
        $('.form-check').addClass("d-none");
        // Handle the form submission
        var form = $(this);
        var formData = form.serialize();
        var url = form.attr("action");
        url += "?" + formData;
        var posting = $.get(url);
        posting.done(function (data) {
            if (data.state.summary == false) {
                // Display question label
                var questionLabel = "Q" + data.data[0]["ID"] + "/" + data.state.numberOfQuestions + ". " + data.data[0]["Questions"];
                $("#question").html(questionLabel);
                // Set the current ID field as the current question number
                $("[name*='id']").val(data.data[0]["ID"]).trigger('change');
                // Display choices
                $.each(data.data, function (key, val) {
                    var checkBoxDiv = $('<div />', { "class": "form-group form-check", "id": "formCheck" + key }).insertBefore("#hintSection");
                    $('<input />', { "type": "checkbox", "name": val["Name"], "id": "checkBox" + key, "class": "form-check-input", "value": val["Correct"] }).appendTo(checkBoxDiv);
                    $('<label />', { "for": 'checkBox' + key, "class": "form-check-label", "text":val["Choices"] }).appendTo(checkBoxDiv);
                });
                // Manipulate html objects after form processing
                $("#submitBtn").html("Submit");
                $("#hintSection").removeClass().addClass("d-block");
                $("#submitBtn").removeClass("d-none");
            } else {
                $("#question").html("Summary");
                $.each(data.data, function (key, val) {
                    var question = "";
                    if ($("#summaryQuestion" + val["ID"]).length == 0) {
                        question += "<details id='summaryQuestion" + val["ID"] + "'>";
                        question += "<summary>Q" + val["ID"] + ". " + val["Questions"] + "</summary";
                        question += "</details>";
                        $("#summary").append(question);
                    }
                    var choice = '';
                    choice += "<div class='form-check'>";
                    if (val["Selected"] == 1) {
                        var selected = "checked";
                    } else {
                        var selected = "";
                    }
                    choice += "<input id='checkBox" + key + "' type='checkbox' class='form-check-input' name='" + val["Name"] + "' value='" + val["Correct"] + "' " + selected + " disabled>";
                    choice += "<label class='form-check-label' for='checkBox'" + key + ">" + val["Choices"] + "</label>";
                    choice += "</div>";
                    $("#summaryQuestion" + val["ID"]).append(choice);
                });
            }
        });
        // Remove answers after submit
        $('.form-check').remove();
    });
    var ddcData = null; 
    va.messagingUtil.setOnDataReceivedCallback(onDataReceived);
    function onDataReceived (resultData){
        ddcData = resultData.data;
    }
    $('[name*="id"]').change(function (event) {
        var id = $('[name*="id"]').val(); 
        $("#hintInfo").empty();
        $("#hintSection").removeAttr("open");
        $.each(ddcData, function (key, val){
            if (val[0] == id) {
                var percent = Number(val[2]).toLocaleString(undefined,{style: 'percent', minimumFractionDigits:2}); 
                $("<li />", {"text": val[1] + " : " + percent} ).appendTo("#hintInfo");
            }
        })
    });
});