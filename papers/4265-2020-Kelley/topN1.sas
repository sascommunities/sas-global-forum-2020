proc means data=myitunes sum noprint;
  var total_time;
  class genre artist;
  output out=summary sum=total_time genre /levels;
run;

proc sort data=summary out=topn;
  where _type_>2;
  by genre descending total_time;
run;

data topn;
  length rank 8;
  label rank="Rank";
  set topn;
  by genre descending total_time;
  if nmiss(of total_time) then delete;
  if first.genre then rank=0;
  rank+1;
  if rank le 10 then output;
run;

ods word file="c:\users\sasdck\onedrive - sas\topN1.docx" 
         options(contents="on" toc_data="on" keep_next="on");
         
title "Top N Artists in Total Playing Time by Genre";
title2 "Time format is (Hours:Minutes).";

proc print data=topn noobs label;
  by genre;
  var rank artist total_time;
  format total_time hhmm.;
run;

ods word close;
title;

