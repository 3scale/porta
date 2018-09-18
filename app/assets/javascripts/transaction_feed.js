(function($) {
  $(document).ready(function() {
    var table           = $("#latest_transactions");
    var tableBody       = table.find("tbody").first();
    var timestamp       = $("#update_timestamp");
    var liveFeedControl = $("#live_feed_control");

    var liveFeed = false;

    var toggleLiveFeed = function() {
      if (liveFeed) {
        liveFeedControl.removeClass("pause");
        liveFeedControl.addClass("play");
        liveFeedControl.text("Live feed: OFF");
      } else {
        liveFeedControl.removeClass("play");
        liveFeedControl.addClass("pause");
        liveFeedControl.text("Live feed: ON");

        update();
      }

      liveFeed = !liveFeed;
    }

    liveFeedControl.click(toggleLiveFeed);

    var update = function() {
      // Disable ajax activity notification, because it would be spinning forever.
      $.ajaxSetup({global: false});  

      tableBody.load(table.attr("data-source"), function(data, status, xhr) {
        timestamp.text((new Date()).toLocaleString());
        if (liveFeed) { setTimeout(update, Math.floor((Math.random()*2000)+1000)); }
      });

      $.ajaxSetup({global: true});  // Enabled it back again.
    }

    toggleLiveFeed();
  });
})(jQuery);
