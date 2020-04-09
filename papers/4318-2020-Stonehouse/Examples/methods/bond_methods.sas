/* Corporate Bond Evaluation Method */

method corporate_bond kind=evaluation;
   t = (maturity_dt - _date_) / 365;
   discount_rt = zero_rt + creditspread_rt;
   _value_ = face_value * exp(-1 * discount_rt * t);
endmethod;

/* T-Bond Evaluation Method */

method treasury_bond kind=evaluation;
   t = (maturity_dt - _date_) / 365;
   _value_ = face_value * exp(-1 * zero_rt * t);
endmethod;