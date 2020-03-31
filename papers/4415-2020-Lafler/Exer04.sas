proc print data=hash_search ;
  var Origin Type Make Model MSRP ;
run ;


proc sql ;
  select Origin, Type, Make, Model, MSRP
    from hash_search ;
quit ;
