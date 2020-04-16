/* Read a file that is encoded as WLATIN1. */
libname saslib '<mypath>/saslibrary';
filename tlist '<mypath>/Quarantine.txt'
         encoding=wlatin1;

data tasklist;
   length task $ 65;
   infile tlist;
   input fmem 1. task &;
   put task;
run;
   
/* Task list for the week. */
title "Quarantine Quandary – Keep your Sanity in Seclusion ";
proc print data=tasklist label;
   label fmem = 'Assignee'
         task = 'Task';
   var fmem task;
run;
