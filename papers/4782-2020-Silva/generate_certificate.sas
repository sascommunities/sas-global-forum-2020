%let local=C:\Papers_ALAN\GLOBALSAS\2020;

goptions reset=all iback="&local\template.PNG" 
imagestyle=fit border;

options noemailfrom emailsys=smtp emailhost=SMTP emailauthprotocol=login emailport=PORT
emailid="e-mail" emailpw="password";
 
data database;
input name $1-37 email $38-66;
cards;
Alan da Silva                        djalan@bol.com.br
yyyyyyyyyyyyyyyyyyyyyyy              yyy@email.com
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz zzz@email.com
;

data database;set database;
call symput('name'||trim(left(_n_)),trim(left(upcase(name))));
call symput('email'||trim(left(_n_)),trim(left(email)));
run;
%put &name1 &email1;
proc sql noprint;
select count(*) into:n from database;
quit;
%put &n;

%macro certificate(local=);
options nodate nonumber leftmargin=1cm rightmargin=1cm topmargin=1cm 
bottommargin=1cm papersize=A4 orientation=landscape;
%do i=1 %to &n;
ods pdf file="&local\certificate &&name&i...pdf" style=printer;
data text;
length function style $30. color $6. text $150.;
retain line 1 xsys ysys '2' hsys '3' x 8;
function='label';color='black';position='5';style="'Bradley Hand ITC'";size=4.3;x=50;y=70;
text="The Department of Statistics of the University of Brasilia";output;
text="certify that &&name&i has successfully completed";x=50;y=65;output;
text="course of study,";x=50;y=60;output;
text="with 4 hours which took place";x=50;y=55;output;
text="from xx to yy May 20xx in University of Brasilia .";x=50;y=50;output;
text="Brasilia, May xx 20xx";x=50;y=35;output;
text="________________________";style="'Times New Roman'";size=3.5;x=50;y=21;output;
text="Prof. Alan Ricardo da Silva";style="'Mistral'";x=50;y=17.5;output;
text="Instructor";x=50;y=14.5;output;
x=38; y=19; function='move';imgpath="&local\signature.jpg";output;
x=60; y=26; imgpath="&local\signature.jpg";style = 'fit';function='image';output;
run;
proc ganno anno=text;run;
ods pdf close;
filename myfile email
to= "&&email&i"
subject= "Certificate of Completion"
attach="&local\certificate &&name&i...pdf";
data _null_;
file myfile;
put "Dear Student, please find attached the certificate of completion of the course of study.";
put " ";
put "Best regards";
put "Prof. Alan Ricardo da Silva";
run;
%end;
%mend certificate;
%certificate(local=&local);
