data hash_match_merge ;
  if 0 then set WORK.COLORS ;
  if _n_ = 1  then do ;
     declare Hash HColors (dataset:'WORK.COLORS') ;
     HColors.DefineKey ('TYPE') ;
     HColors.DefineData ('Exterior_Color',
                         'Interior_Color') ;
     HColors.DefineDone () ;
  end ;
  set SASHELP.CARS (Keep=Origin Type Make Model MSRP) ;
  if HColors.find(key:TYPE) = 0 then output ;
run ;
