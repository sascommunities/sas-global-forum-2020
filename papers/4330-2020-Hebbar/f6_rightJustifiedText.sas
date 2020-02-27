proc template;
  define statgraph rjText;
    beginGraph;
      entryTitle "Right-justified Text: using DataLabelPosition=Left";
      layout overlay;
        scatterPlot x=weight y=height /  group=sex
                dataLabel=name dataLabelPosition=left;
      endLayout;
    endGraph;
  end;
run;

proc sgrender data=sashelp.class(obs=10) template=rjText;
run;
