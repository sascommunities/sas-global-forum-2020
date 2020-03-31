proc print data=hash_match_merge ;
  var Origin Type Make Model Exterior_Color 
      Interior_Color MSRP ;
run ;


proc sql ;
  select Origin, Type, Make, Model, Exterior_Color,
         Interior_Color, MSRP
    from hash_match_merge ;
quit ;
