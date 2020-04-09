METHOD ecl_method kind = evaluation;
    /* Reset the cumulative ECL lifetime value at the first horizon */
    if (SimulationTime eq 1 or basecase eq 1) then do;
        tmp_ECL_Lifetime	= 0;
    end;

    EAD = UPB;
    my_PD = _PD_;
    Expected_Credit_Loss = EAD * _PD_;
    tmp_ECL_Lifetime = tmp_ECL_Lifetime + Expected_Credit_Loss;
    ECL_Lifetime = tmp_ECL_Lifetime;

    _value_ = 1;
ENDMETHOD;