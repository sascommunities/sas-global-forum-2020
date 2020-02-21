proc template;
  define statgraph simpleStats;
    beginGraph;
      entryTitle "Simple Statistics using Expression";
      layout overlay;
        scatterPlot x=msrp y=mpg_highway / name="sp1"
              group=type dataTransparency=0.2;
        referenceLine x=eval(median(msrp)) / lineAttrs=(pattern=shortDash)
              curveLabel="x(*ESC*){unicode '0303'x}" curveLabelAttrs=(size=12);
        referenceLine y=eval(mean(mpg_highway) + std(mpg_highway)) /
              curveLabel="x(*ESC*){unicode '0304'x} + (*ESC*){unicode sigma}"
              curveLabelAttrs=(size=12) lineAttrs=(pattern=dashDashDot);
        referenceLine y=eval(mean(mpg_highway) - std(mpg_highway)) /
              curveLabel="x(*ESC*){unicode '0304'x} - (*ESC*){unicode sigma}"
              curveLabelAttrs=(size=12) lineAttrs=(pattern=dashDashDot);
        discreteLegend "sp1" / across=3 location=inside hAlign=right vAlign=top;
      endLayout;
      entryFootnote halign=left "Weight (in lbs) ranges from " eval(min(weight))
                                " to " eval(max(weight)) ;
    endGraph;
  end;
run;
ods graphics / reset;
proc sgrender data=sashelp.cars template=simpleStats;
run;
