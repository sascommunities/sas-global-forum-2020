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
run; quit;
