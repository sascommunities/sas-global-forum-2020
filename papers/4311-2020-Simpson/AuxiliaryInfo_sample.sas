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

proc summary data = trucksales print maxdec=2;
   var pop_bachelors pop_below_bachelors median_income cost_of_living
      mean_summer_temp mean_winter_temp mean_precip price sales;
run; quit;

proc summary data = trucksales print;
   class area_type;
run; quit;


data trucksales_log;
   set trucksales;
   log_pop_bachelors = log(pop_bachelors);
   log_pop_below_bachelors = log(pop_below_bachelors);
   log_median_income = log(median_income);
   log_price = log(price);
   log_cost_of_living = log(cost_of_living);
   log_mean_precip = log(mean_precip);
   log_sales = log(sales);
   mean_summer_temp_cs = mean_summer_temp;
   mean_winter_temp_cs = mean_winter_temp;
   keep mean_summer_temp_cs mean_winter_temp_cs area_type
      log_pop_bachelors log_pop_below_bachelors log_median_income log_price
      log_cost_of_living log_mean_precip log_sales;
run; quit;

proc standard data = trucksales_log mean=0 std=1 out=trucksales_transformed;
   var mean_summer_temp_cs mean_winter_temp_cs;
run; quit;



proc summary data = trucksales_transformed print maxdec=2;
   var log_pop_bachelors log_pop_below_bachelors log_median_income log_cost_of_living
      mean_summer_temp_cs mean_winter_temp_cs log_mean_precip log_price log_sales;
run; quit;

proc qlim data = trucksales_transformed plots = none;
   class area_type;
   model log_sales = area_type log_pop_bachelors log_pop_below_bachelors
                     log_median_income log_price log_cost_of_living
                     log_mean_precip mean_summer_temp_cs mean_winter_temp_cs;
run; quit;

proc qlim data = trucksales_transformed plots = none;
   class area_type;
   model log_sales = area_type log_pop_bachelors log_pop_below_bachelors
      log_median_income log_price log_cost_of_living
      log_mean_precip mean_summer_temp_cs mean_winter_temp_cs;
   bayes seed = 72834 ntu = 100 mintune = 20 maxtune = 20 nmc = 10000
      statistics = (summary interval prior);
   prior intercept ~ normal(mean = 8.88, var = 10000);
   prior log_pop_bachelors log_pop_below_bachelors log_median_income
      log_cost_of_living log_mean_precip log_price ~ normal(mean = 0, var = 16);
   prior mean_summer_temp_cs mean_winter_temp_cs
      area_type_rural area_type_sub ~ normal(mean = 0, var = 7.62);
   prior _sigma ~ normal(mean = 0, var = 0.48);
run; quit;

data truck_ad;
   call streaminit(92342);
   do i = 1 to 10000;
      race_idx = rand('NORMAL', 0, 1);
      if race_idx >= 0 then
         do;
            race = 'white';
            age = rand('POISSON', 55);
            intercept = 1.1;
         end;
      if race_idx < 0 then
         do;
            race = 'black';
            age = rand('POISSON', 50);
            intercept = 0.7;
         end;
      if race_idx < -1 then
         do;
            race = 'asian';
            age = rand('POISSON', 60);
            intercept = -2.9;
         end;
      if race_idx < -2 then
         do;
            race = 'other';
            age = rand('POISSON', 55);
            intercept = -1.8;
         end;
      price_idx = rand('uniform', 0, 4);
      price = 20;
      if price_idx > 1 then price = 21;
      if price_idx > 2 then price = 22;
      if price_idx > 3 then price = 23;
      prev_purchase = rand('BINOMIAL', 0.3, 1);
      sex = rand('BINOMIAL', 0.7, 1);
      drive_time = INT(exp(log(60) + 0.5*rand('NORMAL', 0, 1)));
      mu = 7.5 + intercept + 0.1 * sex + 0.001 * age +
         0.002 * prev_purchase - 0.002 * drive_time - 0.5 * price;
      prob = 1 / (1 + exp(-mu));
      purchase = rand('BINOMIAL', prob, 1);
      output;
   end;
   keep race sex age price prev_purchase drive_time purchase;
run; quit;

proc summary data = truck_ad print maxdec=2;
   var age sex price drive_time prev_purchase purchase;
run; quit;

proc summary data = truck_ad print;
   class race;
run; quit;

data truck_ad_cs;
   set truck_ad;
   age_cs = age;
   drive_time_cs = drive_time;
   log_price = log(price);
   keep race sex age_cs drive_time_cs prev_purchase log_price purchase;
run; quit;

proc standard data = truck_ad_cs mean=0 std=1 out=truck_ad_transformed;
   var age_cs drive_time_cs;
run; quit;

proc summary data = truck_ad_transformed print maxdec=2;
   var age_cs sex log_price drive_time_cs prev_purchase purchase;
run; quit;

proc qlim data = truck_ad_transformed plots = none;
   class purchase race;
   model purchase = race sex age_cs drive_time_cs prev_purchase log_price
      / discrete(dist = normal);
run; quit;


proc qlim data = truck_ad_transformed plots = none;
   class purchase race;
   model purchase = race sex age_cs drive_time_cs prev_purchase log_price
      / discrete(dist = normal);
   bayes seed = 2341685 ntu = 100 mintune = 20 maxtune = 20 nmc = 10000
      statistics = (summary interval prior);
   prior intercept ~ normal(mean = 14.74, var = 10000);
   prior age_cs drive_time_cs sex prev_purchase
      race_asian race_black race_other ~ normal(mean = 0, var = 0.71);
   prior log_price ~ normal(mean = 0, var = 283);
run; quit;

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
run; quit;

proc standard data = trucksales_count mean=0 std=1 out=truckcount_transformed;
   var mean_summer_temp_cs mean_winter_temp_cs;
run; quit;

proc countreg data = truckcount_transformed plots = none;
   class area_type;
   model sales = area_type log_pop_bachelors log_pop_below_bachelors
      log_median_income log_price log_cost_of_living
      log_mean_precip mean_summer_temp_cs mean_winter_temp_cs;
   bayes seed = 56549 ntu = 100 mintune = 20 maxtune = 20 nmc = 10000
      statistics = (summary interval prior);
   prior intercept ~ normal(mean = 8.88, var = 10000);
   prior log_pop_bachelors log_pop_below_bachelors log_median_income
      log_cost_of_living log_mean_precip log_price ~ normal(mean = 0, var = 16);
   prior mean_summer_temp_cs mean_winter_temp_cs
      area_type_rural area_type_sub ~ normal(mean = 0, var = 7.62);
   prior log_price ~ normal(mean = -0.96, var = 0.25);
run; quit;

