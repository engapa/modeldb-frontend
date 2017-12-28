$(function() {
  var margin = {top: 15, right: 15, bottom: 15, left: 120};
  $(document).on('click', '.md-metrixs-cm-trigger', function(event) {
    var modelId = $(this).data('id');
    var experimentRunId = $(this).data('experimentrunid');
    $('.md-model-id').html(modelId);
    $('.md-input').data('id', modelId);
    $('.md-input').data('experimentRunId', experimentRunId);
    $('.md-metrixs-cm').html("");
    $('.md-metrixs-cm').append($(
    	    '<div id="metrixs-cm-view-table"></div>'+
		    '<div id="metrixs-cm-view"></div>'
	));
    $('#modal-3').addClass('md-show');
	cm_metrixs($(this).data('tp'), $(this).data('fn'), $(this).data('fp'), $(this).data('tn'));
  });

  function cm_metrixs(tp, fn, fp, tn){

        var p = tp + fn;
        var n = fp + tn;

        var accuracy = (tp+tn)/(p+n);
        var f1 = 2*tp/(2*tp+fp+fn);
        var precision = tp/(tp+fp);
        var recall = tp/(tp+fn);

        accuracy = Math.round(accuracy * 100) / 100;
        f1 = Math.round(f1 * 100) / 100;
        precision = Math.round(precision * 100) / 100;
        recall = Math.round(recall * 100) / 100;

        var computedData = [];
        computedData.push({"F1":f1, "PRECISION":precision,"RECALL":recall,"ACCURACY":accuracy});

	    var table = tabulate(computedData, ["F1", "PRECISION","RECALL","ACCURACY"]);

	  	Highcharts.chart('metrixs-cm-view', {

	    chart: {
	        type: 'heatmap',
	        marginTop: 40,
	        marginBottom: 80,
	        plotBorderWidth: 1
	    },

		title: {
            text: null
        },

	    xAxis: {
	        categories: ['0', '1'],
			title: {
                text: 'Prediction'
			}
	    },

	    yAxis: {
	        categories: ['0', '1'],
	        title: {
                text: 'Actual'
			}
	    },

	    colorAxis: {
	        min: 0,
	        minColor: '#FFFFFF',
	        maxColor: Highcharts.getOptions().colors[0]
	    },

	    legend: {
	        align: 'right',
	        layout: 'vertical',
	        margin: 0,
	        verticalAlign: 'top',
	        y: 25,
	        symbolHeight: 280
	    },

	    series: [{
	        name: 'Confusion matrix',
	        borderWidth: 0,
	        data: [[0, 0, tn], [0, 1, fn], [1, 0, fp], [1, 1, tp]],
	        dataLabels: {
	            enabled: true,
	            color: '#000000'
	        }
	    }]

	});
  };

  function tabulate(data, columns) {
    var table = d3.select("#metrixs-cm-view-table").append("table")
            .attr("style", "background-color: #FFFFFF;" + "margin-left: " + margin.left +"px;" + "margin-top: " + margin.top +"px"),
        thead = table.append("thead"),
        tbody = table.append("tbody");

    // append the header row
    thead.append("tr")
        .selectAll("th")
        .data(columns)
        .enter()
        .append("th")
            .text(function(column) { return column; });

    // create a row for each object in the data
    var rows = tbody.selectAll("tr")
        .data(data)
        .enter()
        .append("tr");

    // create a cell in each row for each column
    var cells = rows.selectAll("td")
        .data(function(row) {
            return columns.map(function(column) {
                return {column: column, value: row[column]};
            });
        })
        .enter()
        .append("td")
        .html(function(d) { return d.value; });

    return table;
  };

});
