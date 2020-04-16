/* Convert typographic characters to ASCII */
data tasklist;
   length task $ 45;
   input task &;
   basechar_task = basechar(task);
   punc_task = kpropdata(task, "PUNC");
   datalines;
Read – finish “Les Miserables”.
Binge-watch seasons 1—4 of favorite show.
Takeout from a café
run;

proc print data=tasklist label;
   label task = "Original text"
         basechar_task = "No accented characters"
         punc_task = "ASCII punctuation";
run;

/* Convert accented characters to ASCII */
data _null_;
   task='café';
   basechar_task = basechar(task);
   put task= / ascii_task=;
run;
