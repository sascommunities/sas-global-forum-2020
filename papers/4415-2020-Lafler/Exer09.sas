data _null_ ;
  if 0 then set SASHELP.CARS (Keep=Origin Type Make Model MSRP) ;
  if _n_ = 1 then do ;
     declare Hash HSort (ordered:'d') ; /* declare sort order */
     HSort.DefineKey ('Make','Model','MSRP') ; /* define key */
     HSort.DefineData ('Origin',
                       'Type',
                       'Make',
                       'Model',
                       'MSRP') ; /* define columns of data */
     HSort.DefineDone () ; /* complete hash table definition */
  end ;
  set SASHELP.CARS end=eof ;
  HSort.add () ; /* add data with key to hash object */
  if eof then
     HSort.output(dataset:'Hash_Sorted') ; /* sorted dataset */
run ;
