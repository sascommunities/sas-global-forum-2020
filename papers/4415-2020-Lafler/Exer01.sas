data WORK.COLORS ;
  input @1 Type $8.
       @10 Exterior_Color $10.
       @21 Interior_Color $10. ;
  datalines ;
Hybrid   White      Black
SUV      White      Blue
Sedan    White      Black
Sports   Red        Gold
Truck    Black      Black
Wagon    Blue       Black
;
run ;