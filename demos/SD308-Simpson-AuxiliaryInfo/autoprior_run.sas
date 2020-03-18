%include 'trucksales_data.sas'; /* generate the data set */

/* generate the dataset of all variables to be used in the model
   and their transformation */
data trucksales_vars;
    input variable $20. type $ transform $ response;
    datalines;
sales               numeric log         1
pop_bachelors       numeric log         0
pop_below_bachelors numeric log         0
median_income       numeric log         0
cost_of_living      numeric log         0
mean_summer_temp    numeric std         0
mean_winter_temp    numeric std         0
mean_precip         numeric log         0
price               numeric log         0
area_type           class   none        0
;
run;

/* macro variables used by the autoprior_linear.sas script */

%let variables = trucksales_vars;
%let dataset = trucksales;
%let log_s = 4; 
%let std_s = 4;
%let none_s = 4;
%let class_s = 4;
%let intercept_s = 100;
%let sigma_s = 1;
%let intercept_mean = 0;
%let sigma_mean = 0;


/* Sets up the model and prior for linear regression. */
/* inputs: all %let's above:
     &variables, &dataset, &elasticity_s, &std_s, &none_s, &class_s,
     &intercept_s, &sigma_s, &intercept_mean, &sigma_mean
*/
/* outputs: 
     &model - a macro variable containing the class and model statements
              necessary to fit the desired linear regression model in QLIM
     prior - a dataset containing all prior information 
     &prior - macro variable pointing to prior.
     several intermediate outputs */
%include 'autoprior_linear.sas';

/* Creates the prior statements */
/* input: &prior - a macro variable naming a data set 
                   containing all prior information */
/* output: &prior_stmts - list of all prior statements */
%include 'autoprior_priorstmt.sas';

/* see the resulting priors */
proc qlim data = data_transformed plots = none;
   &model /* includes class statement and model statement */
   bayes seed = 72834 ntu = 2 mintune = 1 maxtune = 1 nmc = 2
      statistics = prior;
   &prior_stmts
run;

/* now make an informative prior for price */
data new_prior;
	set prior;
	if parameter = 'log_price' then do;
	    hyper1 = -1;
		hyper2 = 0.5**2;
		end;
run;

%let prior = new_prior;

%include 'autoprior_priorstmt.sas';

/* see the resulting priors */
proc qlim data = data_transformed plots = none;
   &model /* includes class statement and model statement */
   bayes seed = 72834 ntu = 2 mintune = 1 maxtune = 1 nmc = 2
      statistics = prior;
   &prior_stmts
run;
