var margin  = {top: 20, right: 20, bottom: 100, left: 60},
        width   = (screen.width-1000) - margin.left - margin.right,
        height  = 400 - margin.top - margin.bottom;


var svg = d3.select(".graph")
        .append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.json("https://fitech-app.herokuapp.com/api/data1",function(d){
    return{ x: d3.timeParse("%Y-%m-%d")(d.date), y:(d.value)   }
})
.then(
function (data)
{
    var x = d3.scalePoint()
        .domain([d3.min(data, d => d.date),d3.max(data, d => d.date)])
        .range([ 0, width ])
        .padding(0.1);
    svg.append("g")
      .attr("transform", `translate(0, ${height})`)
      .call(d3.axisBottom(x));

    // Add Y axis
    const y = d3.scaleLinear()
      .domain([0, d3.max(data, function(d) { return +d.value+2; })])
      .range([ height, 0 ]);
    svg.append("g")
      .call(d3.axisLeft(y)
            .ticks(d3.max(data, function(d) { return +d.value+2; })));
    

    // Add the line
    svg.append("path")
      .datum(data)
      .attr("fill", "none")
      .attr("stroke", "#FFFFFF")
      .attr("stroke-width", 1.5)
      .attr("d", d3.line()
        .x(function(d) { return x(d.date) })
        .y(function(d) { return y(d.value) })
        )
}
)

    //console.log(data)
    /*
    const x = d3.scaleTime()
      .domain(d3.extent(data.x))
      .range([ 0, width ]);*/
/*
    var x = d3.scalePoint()
      .domain(data.x)
      .range([ 0, width ]);
    svg.append("g")
      .attr("transform", `translate(0, ${height})`)
      .call(d3.axisBottom(x));

    console.log(x(data.x.forEach(d => d)))
    // Add Y axis
    const y = d3.scaleLinear()
      .domain([0, d3.max(data.y)+2])
      .range([height, 0 ]);
    svg.append("g")
      .call(d3.axisLeft(y))
      .style("font-size","1.2em");


    svg.append("path")
    .datum(data)
    .attr("fill", "none")
    .attr("stroke", "steelblue")
    .attr("stroke-width", 1.5)
    .attr("d", d3.line()
    .x(data.x => console.log('hey'))
    .y(data.y => )
    ).style("font-size","30px")
}*/