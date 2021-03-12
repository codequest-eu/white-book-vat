var CONFIG = {
  apiUrl: ""
};

function onOpen() {
  var ui = SpreadsheetApp.getUi();

  ui.createMenu("Accounts check")
    .addItem("Check data", "checkData")
    .addToUi();
}

function formatDate(date) {
  var date = date ? new Date(date) : new Date();

  var year = date.getFullYear();
  var month = date.getMonth() + 1;
  var day = date.getDate();

  day = day < 10 ? `0${day}` : day;
  month = month < 10 ? `0${month}` : month;

  return `${year}-${month}-${day}`;
}

function checkData() {
  var sheet = SpreadsheetApp.getActiveSheet();

  ["C", "D", "E", "F", "G", "H"].forEach((c) => {
    sheet.getRange(`${c}6:${c}36`).clearContent();
  });

  var dateTimeCell = sheet.getRange("B1");
  var confirmationCell = sheet.getRange("B2");

  var date = dateTimeCell.getValue();

  dateTimeCell.clearContent();
  confirmationCell.clearContent();

  var options = {
    method: "post",
    contentType: "application/json",
    muteHttpExceptions: false,
    payload: JSON.stringify({
      date: formatDate(date),
      data: sheet.getRange("A6:B36").getValues()
    })
  };

  var request = UrlFetchApp.fetch(CONFIG.apiUrl, options);
  var response = JSON.parse(request.getContentText());

  dateTimeCell.setValue(response["date"]);
  confirmationCell.setValue(response["confirmation_url"]);

  for (var index in response.results) {
    var cell = 6 + Number(index);
    var result = response.results[index];

    if (result["checked"]) {
      sheet
        .getRange("C" + cell)
        .setValue(result["found"] ? "1" : "0");
      sheet
        .getRange("D" + cell)
        .setValue(result["valid"] ? "1" : "0");
      sheet
        .getRange("E" + cell)
        .setValue(result["hasVirtual"] && !result["accountFound"] ? "1" : "0");
      sheet
        .getRange("F" + cell)
        .setValue(result["nip"]);
      sheet
        .getRange("G" + cell)
        .setValue(result["company"]);
      sheet
        .getRange("H" + cell)
        .setValue(result["requestId"]);
    }
  }
}
