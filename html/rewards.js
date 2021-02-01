/*----------------------------V1.0------------------------------------
---------------MADE BY GK#8652 FOR SACRP KoTH FiveM-------------------
-----------------------------12.01.21-------------------------------*/

$(function () {
  function display(bool, day) {
    if (bool) {
      $("#container").show();
      $(".locked").show();
      $(day).hide();
    } else {
      $("#container").hide();
    }
  }

  display(false);

  window.addEventListener("message", function (event) {
    var item = event.data;
    if (item.type === "CloseDailyRewards") {
      display(false);
    } else if (item.type === "OpenDailyRewards") {
      display(true, item.day);
    } else if (item.type === "UpdateTime") {
      document.getElementById("unlock-time").innerHTML = item.time;
    }
  });
  document.onkeyup = function (data) {
    if (data.which == 27) {
      $.post("http://dailyrewards/exit", JSON.stringify({}));
      return;
    }
  };
  $("#closebtn").click(function () {
    $.post("http://dailyrewards/exit", JSON.stringify({}));
    return;
  });
});

function redeem(amount) {
  var moneyToSave = amount;
  var music = new Audio("audio/ka-ching.mp3");
  music.play();
  var pdata = JSON.stringify(moneyToSave);
  $.ajax({
    url: "http://dailyrewards/redeem",
    data: pdata,
    type: "POST",
  });
  return;
}
