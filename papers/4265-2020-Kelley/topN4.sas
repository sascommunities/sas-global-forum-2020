ods path (prepend) work.templat(update);
proc template;
  define style styles.mystyle;
  parent = styles.word;
  class contenttitle /
    content = "Top N Artists in Total Playing Time by Genre"
    fontweight = bold
    color=dark blue
    margintop=12pt    
    ;
  class toc2 /
    color=very dark red
    fontstyle=italic
    ;
  class contents /
    borderstyle=double
    bordercolor=green
    ;    
  end;
run;

ods word file="c:\users\sasdck\onedrive - sas\topN4.docx" style=mystyle
         options(contents="on" toc_data="on" keep_next="on");
         
title "Top N Artists in Total Playing Time by Genre";
title2 "Time format is (Hours:Minutes).";

ods proclabel=" ";
proc print data=topn noobs contents="" label;
  by genre;
  var rank artist total_time;
  format total_time hhmm.;  
run;

ods word close;
title;

