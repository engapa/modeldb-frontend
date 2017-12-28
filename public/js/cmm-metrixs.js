$(function() {
  $(document).on('click', '.md-metrixs-cmm-trigger', function(event) {
    var modelId = $(this).data('id');
    var experimentRunId = $(this).data('experimentrunid');
    $('.md-model-id').html(modelId);
    $('.md-input').data('id', modelId);
    $('.md-input').data('experimentRunId', experimentRunId);
    $('.md-metrixs-cmm').html("");
    $('.md-metrixs-cmm').append($(
            '<div id="metrixs-cmm-view-time"><span style="font-size: medium">Time: ' + $(this).data('time') + ' (ms)</span></div>'+
            '<div id="metrixs-cmm-view-cpu"></div>'+
            '<div id="metrixs-cmm-view-mem"></div>'
	));
    $('#modal-4').addClass('md-show');
    var compCateg = ['cpu','mem'];
    for (i in compCateg){
       cmm_metrixs(compCateg[i],
            $(this).data(compCateg[i] + '_min'),
            $(this).data(compCateg[i] + '_max'),
            $(this).data(compCateg[i] + '_avg'));
    };
  });

  function cmm_metrixs(id, min, max, avg) {

      var tooltip = '';
      if (id == 'cpu'){
          tooltip = '%/100';
      } else if (id == 'mem'){
          tooltip = 'MB';
      } else {
          tooltip = '';
      }




      Highcharts.chart('metrixs-cmm-view-'+id, {
          chart: {
              type: 'bar'
          },
          title: {
              text: id + ' consumption'
          },
          xAxis: {
              categories: [id],
              title: {
                  text: null
              }
          },
          yAxis: {
              min: 0,
              title: {
                  text: 'Consumption' + '(' + tooltip + ')',
                  align: 'high'
              },
              labels: {
                  overflow: 'justify'
              }
          },
          plotOptions: {
              bar: {
                  dataLabels: {
                      enabled: true
                  }
              }
          },
          legend: {
              layout: 'vertical',
              align: 'right',
              verticalAlign: 'top',
              x: -40,
              y: 80,
              floating: true,
              borderWidth: 1,
              backgroundColor: ((Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'),
              shadow: true
          },
          credits: {
              enabled: false
          },
          series: [{
              name: 'min',
              data: [min]

          }, {
              name: 'avg',
              data: [avg]

          }, {
              name: 'max',
              data: [max]

          }]
      });
  }
})
