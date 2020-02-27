 proc template;
  define statgraph age_grp_expr;
    beginGraph;
      entryTitle "Generate Groups by Expression";
      layout overlay;
        scatterPlot x=weight y=height / name="sp1"
              group=eval(ifc(age LT 13, "tween", "teen"));
        discreteLegend "sp1" / title='Age Group' location=inside
              hAlign=right vAlign=bottom;
      endLayout;
      entryFootnote halign=left 'group=eval(ifc(age LT 13, "tween", "teen"))';
    endGraph;
  end;
run;
ods graphics / reset;
proc sgrender data=sashelp.class template=age_grp_expr;
run;
