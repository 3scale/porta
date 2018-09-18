var GeneralSettings = {
  usePlan: function (e) {
    var targets = e.target.dataset.targets;

    $("."+targets).toggleClass("hide");
  }
}
