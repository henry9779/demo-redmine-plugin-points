$(document).ready(function() {
  checkHistoryLines();
});

function checkHistoryLines() {
  $('#history .lines').each(function() {
    if ($(this).filter('[id]').length > 0) {
      var id = $(this).attr('id').replace(/_/g, '-');
      var numberTd = $('tr#' + id + ' .sort-number');
      var number = numberTd.text();
      var sortNumber = '#' + number
      insertNumber($(this), sortNumber);
    }
  });
}

function insertNumber(element, number) {
  element.prepend('<strong>' + number + '</strong> ');
}
