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

ods word file="c:\users\sasdck\onedrive - sas\topN5.docx" style=mystyle
         options(contents="on" toc_data="on" toc_type="headings");
         
title "Top N Artists in Total Playing Time by Genre";
title2 "Time format is (Hours:Minutes).";

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

