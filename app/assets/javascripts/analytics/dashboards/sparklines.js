(function($){

  var load_chart = function(event) {
    var $div = $(this),
        unit,
        unitPluralized = $div.attr('data-unit-pluralized'),
        endPoint = $div.attr('data-source'),
        day = 24*60*60*1000,
        today = new Date(Date.now()),
        until_str = today.toISOString().slice(0,10),
        since_str = new Date(today - (30 * day)).toISOString().slice(0,10),
        _data = { metric_name: $div.attr('data-metric'),
                  since: since_str,
                  until: until_str,
                  granularity: 'day' };

    $div.find('.loading').fadeIn();

    $.ajax({
      dataType: 'json',
      data: _data,
      url: endPoint,
      success: function(r) {
        if (r != null) {
          unit = r.metric.unit;

          if(unit.slice(-1) != 's' && r.total != 1) {
            unit = unitPluralized
          }

          $div.find('.spark').sparkline(r.values,
            {type:'line', width: '100%', height: '100%', lineWidth: 1,
             lineColor: '#0088ce', fillColor: false, spotRadius: 0,
             highlightLineColor: '#dfdfdf'}
            );

          var total_txt = r.total.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + " " + unit.substring(0, 10);

          $div.find('.total').html(total_txt);

          $div.find('.loading').fadeOut();
	}
      }
    });
  }

  $(document).ready(function() {
    $('#mini-charts .charts').on('chart:reload', load_chart);
    $('#mini-charts .charts').trigger('chart:reload');
  });

})(jQuery);
