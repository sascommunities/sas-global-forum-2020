/*
 * This pgm will only work correctly if you are running SAS with
 * with -encoding utf8
 */

data _null_;
  call symput('ulabel', kcvt('03b300200398'x, 'utf-16be', 'utf-8'));
  call symput('udf_v1', kcvt('03b100200393'x, 'utf-16be', 'utf-8'));
  call symput('udf_v2', kcvt('03c000200394'x, 'utf-16be', 'utf-8'));
run;

data uni;
  attrib age label="&ulabel"; /* Data set label in utf-8 */
  attrib sex length=$4;   /* NOTE: These are byte lengths: not char lengths */
  attrib name length=$32;
  set sashelp.class(obs=6);
  if _n_ = 2 then /* Alice in Katakana: already utf-8 HEX values */
    name='E382A2E383AAE382B9'x;
  if _n_ = 4 then /* Carol in Kannada: utf-8 literals directly typed in editor */
    name= 'ಕರೂಲ್' ;
  sex = ifc(sex='M', kcvt('2642'x, 'u16b', 'utf8'),
                      kcvt('2640'x, 'u16b', 'utf8')); /* NOTE: short encoding names */
run;

proc format;
  value utf8_udf
  12 = &udf_v1
  13 = &udf_v2
  OTHER= [Best6.]
  ;
run;
proc template;                                                                
  define statgraph uni_utf8;
    beginGraph;
      entryTitle 'Unicode in Data Values using UTF-8 session'; 
      layout overlay / xaxisopts=(labelAttrs=(size=12 weight=bold));
        scatterPlot x=age y=height / name="sp1" group=sex
              datalabel=name
              dataLabelAttrs=(family=GraphUnicodeText:fontFamily size=16);
        discreteLegend "sp1" / title="Sex" valueAttrs=(size=15 weight=bold)
              location=inside halign=right valign=bottom;
      endLayout;                                                           
    endGraph;                                                               
  end;                                                                       
run;

ods graphics / reset;
proc sgrender template=uni_utf8 data=uni;
  format age utf8_udf10.;
run;
