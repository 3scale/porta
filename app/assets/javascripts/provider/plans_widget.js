var PlanWidget = {
  loadPreview: function(planID, callback, url, application_id, upgradeToId){
    var previewBox;
    var previewBoxId =  (application_id == null) ? 'plan-preview-box-new' : 'plan-preview-box-' + application_id

    this.callback = callback;
    this.currentPlan = planID;
    this.application_id = application_id;

    if ($("#" + previewBoxId).length == 1) {
      $("#" + previewBoxId).fadeIn('fast', function () {
        PlanWidget.markCurrentPlan(previewBoxId);
        PlanWidget.showPlan(previewBoxId);
      });
    } else {
      this.createPreviewBox(previewBoxId);

      $.get(url, {application_id: application_id}, function(data) {
        $("#" + previewBoxId + ' .plan-preview-content').html(data);
        PlanWidget.markCurrentPlan(previewBoxId);
        PlanWidget.showPlan(previewBoxId);

        if (upgradeToId) {
          PlanWidget.showPlan (previewBoxId, upgradeToId);
        }
      });
    }

  },

  markCurrentPlan: function(planPreviewBoxId){
    var box = $('#' + planPreviewBoxId);

    var $current = box.find('div.plan-preview[data-plan-id="' + this.currentPlan + '"]');
    $(".current-plan-notice").hide();

    if ($current.length > 0){
      $current.find(".current-plan-notice").show();
      $current.find(".plan-selector").hide();
    } else {
      console.error('Tried to select non-existing plan.');
    }
  }
  ,

  createPreviewBox: function(planPreviewBoxId){
    var html = "<div id='" + planPreviewBoxId + "' class='plan-preview-box'><span class='close-box'></span><div class='plan-preview-content'><div class='loading'><h3>Loading Plans...</h3></div></div></div>";
    $('body').append(html);
  },

  showPlan: function(previewBoxId, planID){
    var box = $('#' + previewBoxId);

    if(typeof(planID) == 'undefined'){
      planID = this.currentPlan;
    }

    box.find('div.plan-preview').hide();
    $('#cboxOverlay').show();
    box.find('div.plan-preview[data-plan-id="'+planID+'"]').fadeIn();

    box.find('.plans-menu li a').removeClass('current');
    box.find('.plans-menu li a[data-plan-id="'+planID+'"]').addClass('current');

  }
};

PlanWidget.bind_events = function (previewBoxId) {
  var box = $("#" + previewBoxId);

  $('a.review-plans').click(function(){
    PlanWidget.loadPreview()
  });

  // Selecting a plan from the plans widget
  box.find(".select-plan-button").click(function(){
    var planID = $(this).attr('data-plan-id');
    var planName = $(this).attr('data-plan-name');
    box.fadeOut();
    PlanWidget.callback(planName, planID);
  });

  // Closing box
  box.find('.close-box').click(function(){
    box.fadeOut('fast');
    $('#cboxOverlay').hide();
  });

  box.find('div.plan-preview:first').show();

  box.find('.plans-menu li a').click(function(){
    var planID = $(this).attr('data-plan-id');
    PlanWidget.showPlan(previewBoxId, planID);
  });
}
