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

			var calendar = $('#calendar').fullCalendar({
				editable: true,        
				header: {
					left: 'prev,next today',
					center: 'title',
					right: 'month,basicWeek'
				},
				firstDay: 1,
				defaultView: 'month',
				height: 600,
				slotMinutes: 15,
				firstHour: 8,
				minTime: 6,
				maxTime: 20,

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

					selectable: true,
					selectHelper: true,

					/* 	This modal is used to create event directly in 
					calendar view using twitter-bootstraps modal plugin */

					//http://arshaw.com/fullcalendar/docs/event_ui/eventDrop/
					eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc){
						updateEvent(event);
					},

					// http://arshaw.com/fullcalendar/docs/event_ui/eventResize/
					eventResize: function(event, dayDelta, minuteDelta, revertFunc){
						updateEvent(event);
					},

					// http://arshaw.com/fullcalendar/docs/mouse/eventClick/
					eventClick: function(event, jsEvent, view){
						// would like a lightbox here.
					},
				});
			});

			/* Hits the right controller and athlete with the update event */
			function updateEvent(the_event) {
				$.update(
					"/athletes/" + the_event.athlete_id + "/events/" + the_event.id,
					{ event: { 
						starts_at: "" + the_event.start,
						ends_at: "" + the_event.end
					}
				},
				function (reponse) { alert('successfully updated task.'); }
			);
		};