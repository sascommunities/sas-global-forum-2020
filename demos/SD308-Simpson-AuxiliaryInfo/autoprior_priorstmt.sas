data _null_;
    eof = 0;
    length prior_stmts varchar(*);
    do i = 1 by 1 until (eof);
        set &prior end=eof;
        select;
                /*	Normal	*/
        when(upcase(distribution) = 'NORMAL') do;
        hypers = catx(", ",
            ifc(Hyper1 = .,' ','mean = '||trim(put(Hyper1,best8. -L))),
            ifc(Hyper2 = .,' ','var = '||trim(put(Hyper2,best8. -L))));
            end;
                /*	T	*/
        when(upcase(distribution) = 'T') do;
        hypers = catx(", ",
            ifc(Hyper1 = .,' ','location = '||trim(put(Hyper1,best8. -L))),
            ifc(Hyper2 = .,' ','df = '||trim(put(Hyper2,best8. -L))));
            end;
                /*	Gamma	*/
        when(upcase(distribution) = 'GAMMA') do;
        hypers = catx(", ",
            ifc(Hyper1 = .,' ','shape = '||trim(put(Hyper1,best8. -L))),
            ifc(Hyper2 = .,' ','scale = '||trim(put(Hyper2,best8. -L))));
            end;
                /*	Inverse Gamma	*/
        when(upcase(distribution) = 'IGAMMA') do;
        hypers = catx(", ",
            ifc(Hyper1 = .,' ','shape = '||trim(put(Hyper1,best8. -L))),
            ifc(Hyper2 = .,' ','scale = '||trim(put(Hyper2,best8. -L))));
            end;                /*	Sqrt Gamma	*/
        when(upcase(distribution) = 'SQGAMMA') do;
        hypers = catx(", ",
            ifc(Hyper1 = .,' ','shape = '||trim(put(Hyper1,best8. -L))),
            ifc(Hyper2 = .,' ','scale = '||trim(put(Hyper2,best8. -L))));
            end;
                /*	Sqrt Inverse Gamma	*/
        when(upcase(distribution) = 'SQIGAMMA') do;
        hypers = catx(", ",
            ifc(Hyper1 = .,' ','shape = '||trim(put(Hyper1,best8. -L))),
            ifc(Hyper2 = .,' ','scale = '||trim(put(Hyper2,best8. -L))));
            end;
                /*	Beta	*/
        when(upcase(distribution) = 'BETA') do;
        hypers = catx(", ",
            ifc(Hyper1 = .,' ','shape1 = '||trim(put(Hyper1,best8. -L))),
            ifc(Hyper2 = .,' ','shape2 = '||trim(put(Hyper2,best8. -L))),
            ifc(Min = .,' ','min = '||trim(put(Min,best8. -L))),
            ifc(Max = .,' ','max = '||trim(put(Max,best8. -L))));
            end;
                /*	Uniform	*/
        when(upcase(distribution) = 'UNIFORM') do;
        hypers = catx(", ",
            ifc(Min = .,' ','min = '||trim(put(Min,best8. -L))),
            ifc(Max = .,' ','max = '||trim(put(Max,best8. -L))));
            end;
        end;
    prior_stmt = 'prior '||strip(Parameter)||' ~ '||strip(distribution)||
        ifc(hypers='', '', '('||strip(hypers)||')');
    if i = 1 then prior_stmts = prior_stmt;
    else prior_stmts = catx(%nrquote("; "), prior_stmts, prior_stmt);
    if eof then call symputx('prior_stmts', cat(prior_stmts, %nrquote("; ")));
    end;
run;
