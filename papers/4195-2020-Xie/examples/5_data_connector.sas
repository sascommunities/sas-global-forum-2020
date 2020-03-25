%cassetup();

/* list caslibs */
caslib _all_ list;

/* Using data connector */
proc casutil;
  load casdata="study/sgf2020_demo/data/class.sas7bdat" /* path of data file */
       incaslib="CASUSER(scnyox)"    /* input caslib      */
       casout="class_cas"            /* CAS table name    */
       importOptions={ filetype="basesas",
                       VarcharConversion=2, 
                       CharMultiplier=2 }; 
  altertable casdata="class_cas" columns={{name="Name", format="$9."}};
quit;
proc contents data=sascas1.class_cas; run;
