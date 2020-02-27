/* Top 3 and bottom 3 zodiacs by US population 
 * Data for illustration only!
 */
data zodiacs;
  length Sign $12;
 input Sign $ Frequency;
 datalines;
 Scorpio      0.094
 Virgo        0.090
 Gemini       0.090
 Sagittarius  0.073
 Leo          0.069
 Aquarius     0.055
 ;
run;

proc format;
  value $ zodiacSymbol
    'Scorpio' = "(*ESC*){unicode '264F'x}"  /* NOTE: unicode expects U16BE */
    'Virgo' =   "(*ESC*){unicode '264D'x}"
    'Gemini' =  "(*ESC*){unicode '264A'x}"
    'Sagittarius' = "(*ESC*){unicode '2650'x}"
    'Leo' =     "(*ESC*){unicode '264C'x}"
    'Aquarius' = "(*ESC*){unicode '2652'x}"
    ;
run;

proc template;
  define statgraph unicodeUDF;
    beginGraph;
      entryTitle "Zodiac Frequency: Unicode Tick Values using User Defined Format";
      layout overlay / xAxisOpts=(tickValueAttrs=GraphUnicodeText(size=14)
                                  display=(tickvalues)
                                  discreteOpts=(tickValueFormat=$zodiacSymbol.)
                                  );
        barChartParm x=Sign y=Frequency / dataTransparency=0.3
                  dataLabel=Sign;
      endLayout;
    endGraph;
  end;
run;

proc sgrender template=unicodeUDF data=zodiacs;
  format Frequency percent. ;
run;
