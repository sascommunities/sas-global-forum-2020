METHOD score_uerate kind = score;
    _PD_= (uerate / 100) ** (4 / uerate_sensitivity);
    _LGD_=in_lgd;
ENDMETHOD;