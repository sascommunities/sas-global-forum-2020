%let nbsp='A0'x; /* ASCII: ’A0’x, UTF-8: ’C2A0’x, EBCDIC: ’41’x */

data plantProd;
  attrib prod label='Production'
          prod_pct label='Production %' format=percent5.2;
  input prod prod_pct Time $ Site $;
  Time=translate(Time, &nbsp., '.');  /* map '.' to non-breaking space */
  datalines;
321 0.0334  w01 US64
373 0.0173  w01 CA41
218 0.0367  w08 US64
420 0.0188  w08 CA41
117 0.0163  w16 US64
461 0.0190  w16 CA41
64  0.0441  w24 US64
320 0.0208  w24 CA41
156 0.0261  w32 US64
620 0.0116  w32 CA41
115 0.0193  w40 US64
700 0.0058  w40 CA41
110 0.0091  w48 US64
642 0.0039  w48 CA41
157 0.0099  w52 US64
586 0.0012  w52 CA41
.   .       ..  US64
.   .       ..  CA41
4657  0.0315  Q1  US64
2491  0.0162  Q1  CA41
1434  0.0251  Q2  US64
2147  0.0112  Q2  CA41
1696  0.0314  Q3  US64
3206  0.0155  Q3  CA41
2895  0.0399  Q4  US64
4174  0.0226  Q4  CA41
.     .       ... US64
.     .       ... CA41
6091  0.0294  H1  US64
4638  0.0145  H1  CA41
4591  0.0364  H2  US64
7380  0.0197  H2  CA41
;
run;

proc template;
  define statgraph chunked; 
    beginGraph;
      entryTitle "Categorical Axis with Gaps" ;      
      layout overlay / xAxisopts=( display=(tickvalues line) type=discrete )
                        yAxisopts=( griddisplay=on offsetmin=0 )
                        y2Axisopts=( offsetmin=0 );
         BarChartParm X=time Y=prod / group=Site name="bar" fillAttrs=(transparency=0.2);
         SeriesPlot X=time Y=prod_pct / group=Site display=all break=true yaxis=y2
                markerattrs=(symbol=squareFilled)
                lineattrs=(pattern=solid thickness=2) ;
          
         DiscreteLegend "bar" / title="Site:";
      endlayout;
      entryFootnote halign=left
            "Uses non-breaking spaces to add axis gaps" ;
    endgraph;
  end;
run;

proc sgrender template=chunked data=plantProd;
run;
