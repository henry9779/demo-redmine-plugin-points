function updatePointAssociatedValues(element, idx) {
  row = $(element).parents('tr');
  convert_value = row.find('td.total-entries input').val() * row.find('td.value input').val();

  row.find('td.convert-value').html(formatCurrency(convert_value));
  $('input#point_lines_attributes_' + idx + '_convert_value').val(formatCurrency(convert_value));

  row.find('td.carry-value input').val(formatCarryValue(convert_value));

	return false;
}

function formatCurrency(num) {
  num = isNaN(num) || num === '' || num === null ? 0.00 : num;
  return parseFloat(num).toFixed(2);
}

function formatCarryValue(num) {
  // 換算公式 個位數 >= 2.5 時，進位公式 進位為 5，若個位數小於 2.5 進位公式 進位為 0
  // EX: 換算 123.4 進位 125 / 換算 122.4 進位 120
  num = isNaN(num) || num === '' || num === null ? 0.00 : num;
  decimal = num % 10
  const value = decimal < 2.5 ? 0 : decimal < 7.5 ? 5 : 10;
  result = num - decimal + value
  return parseFloat(result).toFixed(2);
}

function remove_point_fields(link, idx) {
  $(link).closest('tr').remove();

  var pointLine = $('#point_lines_attributes_' + idx + '_id')
  if (pointLine.length) {
    var pointLineID = pointLine.val();

    $.ajax({
      type: 'DELETE',
      url: '/point_lines/' + pointLineID,
      success: function() {
        pointLine.remove();
      }
    });
  }
}

function remove_entry_lines(link) {
  $(link).closest('tr').remove();

  if ($('tr.entry-line').length === 1) {
    $('tr.entry-line a').remove();
  }
}

function remove_entry_lines_new_record(link) {
  $(link).closest('tr').hide();

  if ($('tr.entry-line:visible').length === 1) {
    $('tr.entry-line a.icon-del').remove();
  }
}

function checkEntryStatus(link, pointLineId) {
  var hiddenEntries = $('tr.entry-line:hidden');
  // 按下確認時，判斷是否有工時被刪除 ( 被隱藏的工時 )，若有，則將 Entry_ID 轉換成 array
  if (hiddenEntries.length > 0) {
    var deleteEntriesValues = hiddenEntries.map(function() {
      return this.id.replace(/(.*)-/,'');
    }).get();

    // 找到 time_entry_ids 隱藏欄位
    var entryIdsInputs = $('input#point_lines_attributes_' + pointLineId + '_time_entry_ids');

    // 如果 time_entry_ids 隱藏欄位 符合 array 的值 就 刪除 該隱藏欄位
    removeEntryInputs(deleteEntriesValues, entryIdsInputs);

    // 更新 要 post 的資料，抓取 spent_on
    var startDate = $('#point_start_date').val().split(' ')[0];
    var endDate = $('#point_end_date').val().split(' ')[0];

    // 將所有 time_entry_ids 隱藏欄位 value map 成 array
    var remainedEntryIds = $('[id$=time_entry_ids]').map(function() { return this.value }).get();

    // 將所需資料 轉成 JSON
    var data = {
      authenticity_token: $('meta[name="csrf-token"]').attr('content'),
      spent_on: JSON.stringify({values: [startDate, endDate]}),
      entries: JSON.stringify(remainedEntryIds)
    }

    // 存下 點數行 描述
    storeDescData();

    // 存下 點數 主旨 及 備註
    storeSubjectAndDesc();

    // 抓 當下網址
    var url = $(location).attr('origin');
    var path = $(location).attr('pathname');
    var redirectUrl = url + path

    // 將資料 使用 form post 再送到 point/new
    openPostPage(redirectUrl, data);
  } else {
    // 若無被刪除工時，則關閉 modal
    hideModal(link);
  }
}

function removeEntryInputs(deleteEntriesValues, entryIdsInputs) {
  $.each(deleteEntriesValues, function(index, value) {
    entryIdsInputs.filter(function () { return this.value === value }).remove();
  });
}

function openPostPage(url, data) {
  var form = document.createElement('form');
  document.body.appendChild(form);
  form.target = '_self';
  form.method = 'post';
  form.action = url;
  for (var name in data) {
      var input = document.createElement('input');
      input.type = 'hidden';
      input.name = name;
      input.value = data[name];
      form.appendChild(input);
  }

  window.onbeforeunload = null;
  form.submit();
  document.body.removeChild(form);
}

function storeDescData() {
  // 抓取當下頁面 所有 點數行
  var rows = $('table.point-lines tr.fields');

  // 將每行 的 用戶名、紫藤案號、備註 轉成 物件
  const descData = rows.map(function() {
    var descInput = $(this).find('td:eq(-2) input');
    var nameTd = $(this).find('td:eq(1)');
    var purpleTd = $(this).find('td:eq(3)');
    var descValue = descInput.val();
    var userName = nameTd.text();
    var purpleNo = purpleTd.text();

    return {
      userName: userName,
      purpleNo: purpleNo,
      descValue: descValue
    }
  }).get();

  // 將 物件 以 JSON 存進 localStorage
  localStorage.setItem('linesDesc', JSON.stringify(descData));
}

function restoreDescData() {
  // 刪除 個別工時後，取回 之前存的 物件
  var descData = JSON.parse(localStorage.getItem('linesDesc'));

  if (descData !== null) {
    descData.forEach(function(Data) {
      dataUserName = Data['userName'];
      dataPurpleNo = Data['purpleNo'];
      dataDescValue = Data['descValue'];

      // 跳轉頁面後，判斷 點數行，有符合 用戶名 及 紫藤號，將 資料備註 更新到 該 tr 備註
      var rows = $('table.point-lines tr.fields');
      rows.each(function(index) {
        var userNameTd = $("td.user-name", this);
        var purpleNoTd = $("td.purple-no", this);
        var descInput = $("td.description input", this);

        var userNameText = userNameTd.text();
        var purpleNoText = purpleNoTd.text();

        if (userNameText === dataUserName && purpleNoText === dataPurpleNo) {
          descInput.val(dataDescValue);
        }
      });
    });

    // 結束 刪除 localStorage 資料
    localStorage.removeItem('linesDesc');
  }
}

function storeSubjectAndDesc() {
  var pointSubject = $('#point_subject');
  var pointDesc = $('#point_description');
  var subjectValue = pointSubject.val();
  var descValue = pointDesc.val();

  var pointData = {
    subject: subjectValue,
    desc: descValue
  }

  localStorage.setItem('pointData', JSON.stringify(pointData));
}

function restoreSubjectAndDesc() {
  var pointData = JSON.parse(localStorage.getItem('pointData'));

  if (pointData !== null) {
    var subjectValue = pointData['subject'];
    var descValue = pointData['desc'];

    $('#point_subject').val(subjectValue);
    $('#point_description').val(descValue);

    localStorage.removeItem('pointData');
  }
}
