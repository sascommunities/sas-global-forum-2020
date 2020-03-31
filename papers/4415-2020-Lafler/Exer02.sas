proc print data=WORK.COLORS ;
  var Type Exterior_Color Interior_Color ;
run ;


proc sql ;
  select Type, Exterior_Color, Interior_Color
    from WORK.COLORS ;
quit ;
