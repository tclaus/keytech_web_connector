// Checks the API

$('#testURL').click(function(event) {
   event.preventDefault();
   url = $('#keytechAPIURL').val();
   url = url + '/serverinfo';
   alert(url);
   $.ajax(url, {
      success: function(data) {
         $('#testURL').text('OK');
         // Color green:
      },
      error: function() {
         $('#testURL').text('Failed');
         // color: red (CSS ändern)
      }
   });
});
