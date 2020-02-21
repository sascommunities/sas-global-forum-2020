proc template;                                                                
  define statgraph selections;
    dynamic upLimit "low end of high mpg"
            lowLimit "upper end of low mpg";
    beginGraph / designHeight=600;
      EntryTitle "Vehicles with Extreme Highway MPG (2004)"; 
      layout lattice / rows=2 columnDataRange=union rowDataRange=union
                        rowGutter=10px;
        columnAxes;
          columnAxis / label="MSRP($)";
        endColumnAxes;

        rowAxes;
          rowAxis / label=eval(colLabel(mpg_highway));
          rowAxis / label=eval(colLabel(mpg_highway));
        endRowAxes;
        cell; 
          cellHeader;
            Entry "MPG " {unicode '2265'x} " " upLimit;
          endCellHeader;
          scatterPlot x=eval(ifn(mpg_highway >= upLimit, msrp, .))
                      y=eval(ifn(mpg_highway >= upLimit, mpg_highway, .)) /
                      group=make dataLabel=model dataLabelAttrs=(size=10);
        endCell;
        cell;
          cellHeader;
            Entry "MPG " {unicode '2264'x} " " lowLimit;
          endCellHeader;
          scatterPlot x=eval(ifn(mpg_highway <= lowLimit, msrp, .))
                    y=eval(ifn(mpg_highway <= lowLimit, mpg_highway, .)) /
                    group=make dataLabel=model dataLabelAttrs=(size=10);
        endCell;
      endLayout;
    endGraph;                                                               
  end;                                                                       
run;

ods graphics / reset height=600px labelMax=600;
proc sgrender template=selections data=sashelp.cars;
  dynamic upLimit=44 lowLimit=16 ;
run;
