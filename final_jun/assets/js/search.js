$(document).ready(function(){
  $("#myInput ").on("keyup", function() {
    var value = $(this).val().toLowerCase();
    $("#myTable #search").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    });
  });
});
