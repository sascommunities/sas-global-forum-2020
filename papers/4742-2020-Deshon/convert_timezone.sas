/******************************************************************************/
/* convert_timezone.sas --                                                    */
/* This macro converts any datetime value from any time zone to any other     */
/* time zone.  Use it any place you would use a numeric function.             */
/*                                                                            */
/* USAGE:                                                                     */
/*    %convert_timezone(in_datetime,from_timezone,to_timezone)                */
/*                                                                            */
/* EXAMPLE:                                                                   */
/*    Convert the time in Atlanta to the time in India:                       */
/*                                                                            */
/*    data _null_;                                                            */
/*      now_edt = '08APR2019:12:37:00'dt;                                     */
/*      now_ist = %convert_timezone(now_edt,edt,ist);                         */
/*      format now_edt datetime19.;                                           */
/*      format now_ist datetime19.;                                           */
/*      putlog _all_;                                                         */
/*    run;                                                                    */
/*                                                                            */
/*    RESULT:                                                                 */
/*      now_edt=08APR2019:12:37:00 now_ist=08APR2019:22:07:00 _ERROR_=0 _N_=1 */
/*                                                                            */
/******************************************************************************/

%macro convert_timezone(in_datetime,from_timezone,to_timezone);

%global readonly

  ist_offset              /** India Standard Time          **/
  art_offset              /** Argentina Time               **/  /** Argentina **/  /** No DST in Argentina! **/
  hoa_offset              /** Hora Oficial Argentina       **/  /** Argentina **/  /** No DST in Argentina! **/

  eet_offset              /** Eastern European Time        **/
  eest_offset             /** Eastern European Summer Time **/
  cet_offset              /** Central European Time        **/  /** Germany **/
  cest_offset             /** Central European Summer Time **/  /** Germany **/
  wet_offset              /** Western European Time        **/
  west_offset             /** Western European Summer Time **/

  gmt_offset              /** Greenwich Mean Time          **/
  utc_offset              /** Coordinated Universal Time   **/

  est_offset              /** Eastern Standard Time        **/
  edt_offset              /** Eastern Daylight Time        **/
  cst_offset              /** Central Standard Time        **/
  cdt_offset              /** Central Daylight Time        **/
  mst_offset              /** Mountain Standard Time       **/
  mdt_offset              /** Mountain Daylight Time       **/
  pst_offset              /** Pacific Standard Time        **/
  pdt_offset              /** Pacific Daylight Time        **/
  zulu_offset             /** Zulu Time (UTC)              **/

  ;

%let ist_offset  = +5.5;  /** India Standard Time          **/
%let art_offset  = -3.0;  /** Argentina Time               **/  /** Argentina **/
%let hoa_offset  = -3.0;  /** Hora Oficial Argentina       **/  /** Argentina **/

%let eet_offset  = +2.0;  /** Eastern European Time        **/
%let eest_offset = +3.0;  /** Eastern European Summer Time **/
%let cet_offset  = +1.0;  /** Central European Time        **/  /** Germany **/
%let cest_offset = +2.0;  /** Central European Summer Time **/  /** Germany **/
%let wet_offset  = +0.0;  /** Central European Time        **/
%let west_offset = +1.0;  /** Central European Summer Time **/

%let gmt_offset  = +0.0;  /** Greenwich Mean Time          **/
%let utc_offset  = +0.0;  /** Coordinated Universal Time   **/

%let est_offset  = -5.0;  /** Eastern Standard Time        **/
%let edt_offset  = -4.0;  /** Eastern Daylight Time        **/
%let cst_offset  = -6.0;  /** Central Standard Time        **/
%let cdt_offset  = -5.0;  /** Central Daylight Time        **/
%let mst_offset  = -7.0;  /** Mountain Standard Time       **/
%let mdt_offset  = -6.0;  /** Mountain Daylight Time       **/
%let pst_offset  = -8.0;  /** Pacific Standard Time        **/
%let pdt_offset  = -7.0;  /** Pacific Daylight Time        **/
%let zulu_offset =  0.0;  /** Zulu Time (UTC)              **/

%if
  %symexist(&&from_timezone._offset)             AND
  %symexist(&&to_timezone._offset)               AND
  %sysfunc(nmiss(&&&from_timezone._offset)) eq 0 AND
  %sysfunc(nmiss(&&&to_timezone._offset))   eq 0
    %then %do;

  (ifn(missing(&in_datetime),.,              /** If input time is null, return a null.  Otherwise... **/

    (&in_datetime                            /** Input datetime             **/
            -                                /** MINUS offset               **/
     ((&&&from_timezone._offset) * 60 * 60)  /** Convert to UTC             **/
            +                                /** PLUS offset                **/
     ((&&&to_timezone._offset) * 60 * 60))   /** Convert to output datetime **/
   ,.))                                      /** If result time is null, return a null.  **/

%end;

%else %do;
  %put ERROR: Time zone abbreviation &from_timezone or &to_timezone not defined in convert_timezone macro!;
%end;

%mend;

