proc print data=Hash_Sorted ;
  var Origin Type Make Model MSRP ;
run ;


proc sql ;
  select Origin, Type, Make, Model, MSRP
    from Hash_Sorted ;
quit ;

