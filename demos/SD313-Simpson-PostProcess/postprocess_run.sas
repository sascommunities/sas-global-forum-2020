data trucksales;
    call streaminit(768234);
    rural_intercept = 10;
    urban_intercept = 8;
    suburban_intercept = 9;
    do i = 1 to 100;
        population = rand('POISSON', 50000);
        prop_bachelors = rand('BETA', 10, 30);
        pop_bachelors = INT(prop_bachelors * population);
        pop_below_bachelors = INT((1 - prop_bachelors) * population);
        median_income = INT(exp(log(40000) + .3*rand('NORMAL', 0, 1)));
        price = ROUND(25000 + 1000 * rand('NORMAL', 0, 1), 100);
        cost_of_living = INT(130 + 20*rand('NORMAL', 0, 1));
        mean_summer_temp = INT(85 + 5*rand('NORMAL', 0, 1));
        mean_winter_temp = INT(35 + 8*rand('NORMAL', 0, 1));
        mean_precip = INT(exp(log(22) + .4*rand('NORMAL', 0, 1)));
        rural_idx = rand('NORMAL', 0, 1);
        if rural_idx < -0.7 then area_type = 'rural';
        if rural_idx >  0.7 then area_type = 'urban';
        if abs(rural_idx) <= 0.7 then area_type = 'sub';
        if area_type = 'rural' then intercept = rural_intercept;
        if area_type = 'urban' then intercept = urban_intercept;
        if area_type = 'sub'   then intercept = suburban_intercept;
        xbeta = intercept - 1 + 0.03 * log(pop_bachelors) +
            0.04 * log(pop_below_bachelors) + 0.04 * log(median_income) +
            - 0.5 * log(price) - 0.02 * log(cost_of_living) +
            - 0.02 * log(mean_summer_temp) + 0.3 * log(mean_winter_temp) +
            0.02 * log(mean_precip);
        sales = CEIL(exp(xbeta + 0.05 * rand('NORMAL', 0, 1)));
        output;
        end;
    keep pop_bachelors pop_below_bachelors median_income price cost_of_living
        mean_summer_temp mean_winter_temp mean_precip area_type sales;
run;

data trucksales;
    set trucksales end = eof;
    output;
    if eof then do i = 1 to 5;
        population = rand('POISSON', 50000);
        prop_bachelors = rand('BETA', 10, 30);
        pop_bachelors = INT(prop_bachelors * population);
        pop_below_bachelors = INT((1 - prop_bachelors) * population);
        median_income = INT(exp(log(40000) + .3*rand('NORMAL', 0, 1)));
        cost_of_living = INT(130 + 20*rand('NORMAL', 0, 1));
        mean_summer_temp = INT(85 + 5*rand('NORMAL', 0, 1));
        mean_winter_temp = INT(35 + 8*rand('NORMAL', 0, 1));
        mean_precip = INT(exp(log(22) + .4*rand('NORMAL', 0, 1)));
        rural_idx = rand('NORMAL', 0, 1);
        if rural_idx < -0.7 then area_type = 'rural';
        if rural_idx >  0.7 then area_type = 'urban';
        if abs(rural_idx) <= 0.7 then area_type = 'sub';
        sales = .;
        price = 25000;
        output;
        end;
    keep pop_bachelors pop_below_bachelors median_income price cost_of_living
        mean_summer_temp mean_winter_temp mean_precip area_type sales;
run;


data trucksales_count;
    set trucksales;
    log_pop_bachelors = log(pop_bachelors);
    log_pop_below_bachelors = log(pop_below_bachelors);
    log_median_income = log(median_income);
    log_price = log(price);
    log_cost_of_living = log(cost_of_living);
    log_mean_precip = log(mean_precip);
    mean_summer_temp_cs = mean_summer_temp;
    mean_winter_temp_cs = mean_winter_temp;
    keep mean_summer_temp_cs mean_winter_temp_cs area_type
        log_pop_bachelors log_pop_below_bachelors log_median_income log_price
        log_cost_of_living log_mean_precip sales;
run;

proc standard data = trucksales_count mean=0 std=1 out=truckcount_transformed;
    var mean_summer_temp_cs mean_winter_temp_cs;
run;

proc countreg data = truckcount_transformed plots = none;
    class area_type;
    model sales = area_type log_pop_bachelors log_pop_below_bachelors
        log_median_income log_price log_cost_of_living
        log_mean_precip mean_summer_temp_cs mean_winter_temp_cs;
    score out = trucksales_pred pred = pred;
run;

proc countreg data = truckcount_transformed plots = none;
    class area_type;
    model sales = area_type log_pop_bachelors log_pop_below_bachelors
        log_median_income log_price log_cost_of_living
        log_mean_precip mean_summer_temp_cs mean_winter_temp_cs;
    bayes seed = 56549 ntu = 100 mintune = 20 maxtune = 20 nmc = 100000
        statistics = (summary interval) outpost = truckcount_post;
    prior intercept ~ normal(mean = 8.88, var = 10000);
    prior log_pop_bachelors log_pop_below_bachelors log_median_income
        log_cost_of_living log_mean_precip log_price ~ normal(mean = 0, var = 16);
    prior mean_summer_temp_cs mean_winter_temp_cs
        area_type_rural area_type_sub ~ normal(mean = 0, var = 7.62);
    prior log_price ~ normal(mean = -0.96, var = 0.25);
run;

data truckcount_post;
    set truckcount_post;
    drop logpost loglike;
    rename log_pop_bachelors = b_log_pop_bachelors
        log_pop_below_bachelors = b_log_pop_below_bachelors
        log_median_income = b_log_median_income
        log_price = b_log_price
        log_cost_of_living = b_log_cost_of_living
        log_mean_precip = b_log_mean_precip
        mean_summer_temp_cs = b_mean_summer_temp_cs
        mean_winter_temp_cs = b_mean_winter_temp_cs;
run;

data trucksales_missing;
    set trucksales;
    if sales = .;
run;

proc print data = trucksales_missing;
run;

data trucksales_missing;
    set truckcount_transformed;
    if sales = .;
run;

data truckcount_postpred;
    set truckcount_post;
    do j = 1 to nobs;
        set trucksales_missing point = j nobs = nobs;
        location = j;
        loglambda = intercept +
            log_pop_bachelors * b_log_pop_bachelors +
            log_pop_below_bachelors * b_log_pop_below_bachelors +
            log_median_income * b_log_median_income +
            log_price * b_log_price +
            log_cost_of_living * b_log_cost_of_living +
            log_mean_precip * b_log_mean_precip +
            mean_summer_temp_cs * b_mean_summer_temp_cs +
            mean_winter_temp_cs * b_mean_winter_temp_cs;
        if area_type = 'rural' then loglambda = loglambda + area_type_rural;
        if area_type = 'sub'   then loglambda = loglambda + area_type_sub;
        lambda = exp(loglambda);
        pred = rand('POISSON', lambda);
        output;
        end;
    keep iteration location pred;
run;

proc transpose data = truckcount_postpred 
               out = truckcount_postpred 
               prefix = pred;
    by iteration;
    id location;
    var pred;
run;

data truckcount_postpred;
    set truckcount_postpred;
    drop _NAME_;
run;

proc means data = truckcount_postpred maxdec = 2
           n mean std p5 p25 p50 p75 p95;
   var pred1-pred5;
run;


%postsum(data = truckcount_postpred, var = pred1-pred5)
%postint(data = truckcount_postpred, var = pred1-pred5)

%ess(data = truckcount_postpred, var = pred1-pred5)
%geweke(data = truckcount_postpred, var = pred1-pred5)
%heidel(data = truckcount_postpred, var = pred1-pred5)
%mcse(data = truckcount_postpred, var = pred1-pred5)
%raftery(data = truckcount_postpred, var = pred1-pred5)
