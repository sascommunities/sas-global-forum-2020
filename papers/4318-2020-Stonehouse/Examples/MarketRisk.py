#%% Import Packages
import riskpy

import swat
import os
from sys import platform
import datetime as dt
import seaborn  as sns
import matplotlib.pyplot as plt

from os.path import join as path

my_run=riskpy.SessionContext(session=swat.CAS(), caslib="CASUSER")

# Set output location
if platform == "win32":
    # Windows...
    output_dir = 'u:\\temp'
else:
    # platform == "linux" or platform == "linux2" or platform == "darwin":
    output_dir = '/tmp'



#%% Create market data object
market_data = riskpy.MarketData(
        current    = path("datasources","MarketRisk","current.xlsx"),
        historical = path("datasources","MarketRisk","history.xlsx"))


#%% Simulate Market States
market_states = riskpy.MarketStates(
        market_data       = market_data,
        as_of_date        = dt.datetime(2020,3,2),
        num_horizons      = 10,
        num_draws         = 250)

market_states.generate(session_context=my_run)
print(market_states.states.tail())


#%% Read and configure instrument data
portfolio = riskpy.Portfolio(
        data = path("datasources","MarketRisk","portfolio.xlsx"),
        class_variables = ['Desk', 'Region', 'insttype'])


#%% Read evaluation methods
methods = riskpy.MethodLib(
        name       = "evalmethods", 
        method_code= path("methods","bond_methods.sas"))


#%% Evaluate Portfolio
values = riskpy.Values(
        session_context  = my_run,
        portfolio        = portfolio,
        market_states    = market_states,
        method_lib       = methods,
        mapping          = {"CorporateBond":"corporate_bond", "TBond":"treasury_bond"})

values.evaluate(write_prices=True)


#%% Query Results
results = riskpy.Results(
    values=values, 
    out_type='values',
    horizons=1,
    session_context=my_run)
vals = results.query(max_rows=500)

results.out_type = 'stat'
results.statistics = ['VAR', 'ES']
results.outvars = 'PL'

stats = results.query().to_frame()
VaR_95 = stats['VAR'][0]
ES_95  = stats['ES'][0]

results.alpha = 0.01
stats = results.query().to_frame()
VaR_99 = stats['VAR'][0]
ES_99  = stats['ES'][0]

results.requests = [ [], 'desk', ['desk','region','insttype'] ]
stats_tree = results.query()
stats_tree.to_excel(path(output_dir, "stats.xlsx"))

#%% Plot density
loss = -1*vals['PL']

sns.set_style("darkgrid")
sns.distplot(loss, hist=True, kde=True, bins=30, color='darkblue', axlabel="Loss Amount",
             hist_kws={'edgecolor':'black'},
             kde_kws={'linewidth': 4})
varline = plt.axvline(VaR_99, color='yellow')
esline  = plt.axvline(ES_99,  color='red')
plt.legend(handles=[varline, esline], labels=["VaR", "ES"])
plt.title("Histogram and Density Plot of Loss Distribution")


#%% Print VaR and ES
print("\n--------------------------------------------")
print("Alpha              = 0.05")
print("Value at Risk      = $" + str(round(VaR_95, ndigits=2)))
print("Expected Shortfall = $" + str(round(ES_95, ndigits=2)))
print("--------------------------------------------")
print("\n--------------------------------------------")
print("Alpha              = 0.01")
print("Value at Risk      = $" + str(round(VaR_99, ndigits=2)))
print("Expected Shortfall = $" + str(round(ES_99, ndigits=2)))
print("--------------------------------------------")

                    

