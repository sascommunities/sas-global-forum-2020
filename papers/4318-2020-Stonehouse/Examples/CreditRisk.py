#%% Import packages
import swat
import pandas as pd
import os
from sys import platform
import riskpy
from os.path import join as path

#%% 1a. Start the CAS session
if "CASHOST" in os.environ:
    # Create a session to the CASHOST and CASPORT variables set in your environment
    conn = riskpy.SessionContext(session=swat.CAS(),
                                 caslib="CASUSER")
else:
    # Otherwise set this to your host and port:
    host = "riskpy.rqs-cloud.sashq-d.openstack.sas.com"
    port = 5570
    conn = riskpy.SessionContext(session=swat.CAS(host, port), caslib="CASUSER")

#%% 1b. Setup input/output paths - change as needed for your running environment:
base_dir = '.'

# Set output location
if platform == "win32":
    # Windows...
    output_dir = 'u:\\temp'
else:
    # platform == "linux" or platform == "linux2" or platform == "darwin":
    output_dir = '/tmp'

#%% 3. Create object: scenarios
mkt_data = riskpy.MarketData(
    current      = pd.DataFrame(data={'uerate': 6.0}, index=[0]),
    risk_factors = ['uerate'])

#%% Create scenarios
my_scens = riskpy.Scenarios(
    name        = "my_scens",
    market_data = mkt_data,
    data        = path("datasources","CreditRisk",'uerate_scenario.xlsx'))

#%% 4. Create object: Counterparties
cpty_df = pd.read_excel(path("datasources","CreditRisk",'uerate_cpty.xlsx'))
loan_groups = riskpy.Counterparties(data=pd.read_excel(
    path("datasources","CreditRisk",'uerate_cpty.xlsx')))
loan_groups.mapping = {"cpty1": "score_uerate"}

#%% 5. Create object scoring methods
score_code_file=(path("methods","CreditRisk",'score_uerate.sas'))
scoring_methods = riskpy.MethodLib(
    method_code=path("methods","CreditRisk",'score_uerate.sas'))

#%% 6.Generate scores (Scores object)
my_scores = riskpy.Scores(counterparties=loan_groups,
                          scenarios=my_scens,
                          method_lib=scoring_methods)
my_scores.generate(session_context=conn, write_allscore=True)

print(my_scores.allscore.head())
allscore_file = path(output_dir, 'simple_allscores.xlsx')
my_scores.allscore.to_excel(allscore_file)

#%% 7. Create object: Portfolio
portfolio = riskpy.Portfolio(
    data=path("datasources","CreditRisk",'retail_portfolio.xlsx'),
    class_variables = ["region", "cptyid"])

#%% 8. Create object: Evaluation methods

eval_methods = riskpy.MethodLib(
    method_code=path("methods","CreditRisk",'credit_method2.sas'))

#%% 9. Run analysis (Values object)
my_values = riskpy.Values(
                          session_context=conn,
                          portfolio=portfolio,
                          output_variables=["Expected_Credit_Loss"],
                          scenarios=my_scens,
                          scores=my_scores,
                          method_lib=eval_methods,
                          mapping = {"Retail": "ecl_method"})
my_values.evaluate(write_prices=True)
allprice_df = my_values.fetch_prices(max_rows=100000)
print(my_values.allprice.head())
allprice_file = path(output_dir, 'creditrisk_allprice.xlsx')
allprice_df.to_excel(allprice_file)

#%% 10. Get results 
results = riskpy.Results(
    session_context=conn,
    values=my_values,
    requests=["_TOP_", ["region"]],
    out_type="values"
)
results_df = results.query().to_frame()
print(results_df.head())
rollup_file = path(output_dir, 'creditrisk_rollup_by_region.xlsx')
results_df.to_excel(rollup_file)

