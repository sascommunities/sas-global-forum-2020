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

options nodate nonumber;

ods escapechar='^';
ods word file="c:\users\sasdck\onedrive - sas\topN6.docx" style=mystyle
         options(toc_data="on" toc_type="headings");

proc odstext;
  p "Top N Artists in Total Playing Time by Genre"/style=contenttitle{just=c};
  p "^{run {TOC \f C \h \z \p "" ""}}";
run;

title "Top N Artists in Total Playing Time by Genre";
title2 "Time format is (Hours:Minutes).";

options date number;

proc odstext pagebreak=yes;
  p ""/style={fontsize=.5pt}; /*-- 1/144th of an inch --*/
run;

%macro doOneGenre(val);
proc odstext;
  h2 "&val";  /*-- h2 matches up with toc2. --*/
run;  
proc odslist data=topn(where=(genre="&val"));
  item strip(put(artist,$255.)) || " (" ||  strip(put(total_time,hhmm.)) || ")"/style={liststyletype=decimal};
run;
%mend;

%doOneGenre(Alternative Rock);
%doOneGenre(Blues);
%doOneGenre(Children%STR(%')s);
%doOneGenre(Classical);
%doOneGenre(Country);
%doOneGenre(Country & Folk);
%doOneGenre(Folk);
%doOneGenre(Folk-Rock);
%doOneGenre(Jazz);
%doOneGenre(Pop);
%doOneGenre(%NRSTR(R&B));
%doOneGenre(Religious);
%doOneGenre(Rock);
%doOneGenre(Soundtrack);
%doOneGenre(Traditional);

ods word close;
title;

