$(document).ready(function() {

    var date = new Date();
    var d = date.getDate();
    var m = date.getMonth();
    var y = date.getFullYear();

    /*	Uses the pathname in the browser to retrieve
	the right athlete_id to create a path to the right
	event */
    var pathname = window.location.pathname;
    var match = pathname.match(/\d+/)

    if(match)
    {
	var athlete_id = parseInt(match[0], 10);
    }

    $('#start_date_cal').datepicker({
	format: "dd-mm-yyyy",
        autoclose: true
    });

    $('#end_date_cal').datepicker({
	format: "dd-mm-yyyy",
        autoclose: true
    });
    $('#start_date_pdf').datepicker({
	format: "dd-mm-yyyy",
        autoclose: true
    });

    $('#end_date_pdf').datepicker({
	format: "dd-mm-yyyy",
        autoclose: true
    });
    


    var calendar = $('#calendar').fullCalendar({    
	header: {
	    left: 'prev,next today',
	    center: 'title',
	    right: 'month,agendaWeek'
	},
	firstDay: 1,
	defaultView: 'month',
	allDaySlot: false,
	height: 600,
	firstHour: 8,
	minTime: 6,
	maxTime: 12,
	editable: false,

	loading: function(bool){
	    if (bool) 
		$('#loading').show();
	    else 
		$('#loading').hide();
	},		

	/* 	This eventsource hits the right athletes eventcontroller on 
		the index action */
	eventSources: [{
	    url: "/athletes/" + athlete_id + "/events/",
	    color: '#FFFFF',
	    textColor: 'white',
	    ignoreTimezone: true
	}],

	timeFormat: 'h:mm t{ - h:mm t} ',
	dragOpacity: "0.5",

	/* 	This modal is used to create event directly in 
		calendar view using twitter-bootstraps modal plugin */

	eventClick: function(event, jsEvent, view){
	    event_url = "/athletes/" + athlete_id + "/events/" + event.id;
	    window.open(event_url, "_self");
	    return false;
	}
    });
});
