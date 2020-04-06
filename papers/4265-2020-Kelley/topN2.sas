ods path (prepend) work.templat(update);
proc template;
  define style styles.mystyle;
  parent = styles.word;
  class toc2 /
    color=very dark red
    fontstyle=italic
    ;  
  end;
run;

ods word file="c:\users\sasdck\onedrive - sas\topN2.docx" style=mystyle
         options(contents="on" toc_data="on" keep_next="on");
         
title "Top N Artists in Total Playing Time by Genre";
title2 "Time format is (Hours:Minutes).";

ods proclabel=" ";
proc print data=topn noobs label contents="";
  by genre;
  var rank artist total_time;
  format total_time hhmm.;
run;

ods word close;
title;

