proc fcmp outlib=sasuser.cmplib.test;
/* http://people.maths.ox.ac.uk/trefethen/bmi.html */
  function BMI(height_inch, weight_lb);
    return (703 * weight_lb / (height_inch ** 2));
  endsub;
  function newBMI(height_inch, weight_lb);
    return (5734 * weight_lb / (height_inch ** 2.5));
  endsub;
  function BMIDiff(height_inch, weight_lb);
    return (newBMI(height_inch, weight_lb)
              - BMI(height_inch, weight_lb));
  endsub;
  function absBMIDiff(height_inch, weight_lb);
    return(abs(BMIDiff(height_inch, weight_lb)));
  endsub;
run; quit;
options cmplib=sasuser.cmplib;

proc template;
  define statgraph bmi;
    beginGraph;
      rangeAttrMap name="ram1";
        range min - 0 / rangeColorModel=(green white);
        range 0 - max / rangeColorModel=(white red);
      endRangeAttrMap;
      rangeAttrVar var=eval(BMIDiff(height, weight)) attrVar=bmiDiff attrMap="ram1";
      entryTitle "BMIs for sashelp.class: New vs Old";
      layout overlay;
        bubblePlot x=weight y=height size=eval(absBMIDiff(height, weight)) /
              name="bp1"
              dataTransparency=0.3
              colorResponse=bmiDiff
              ;
        continuousLegend "bp1" / title='New - Old' vAlign=bottom;
      endLayout;
      entryFootnote halign=left "BMI formulae from: http://people.maths.ox.ac.uk/trefethen/bmi.html";
    endGraph;
  end;
run;

proc sgrender data=sashelp.class template=bmi;
run;
