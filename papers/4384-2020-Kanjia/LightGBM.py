import lightgbm as lgb
import os
import sys
import matplotlib as mpl
if os.environ.get('DISPLAY','') == '':
    print('no display found. Using non-interactive Agg backend')
    mpl.use('Agg')
import matplotlib.pyplot as plt

# Make sure nominals are category
dtypes = dm_inputdf.dtypes
nominals = dtypes[dtypes=='object'].keys().tolist()
for col in nominals: 
    dm_inputdf[col] = dm_inputdf[col].astype('category')

# Training set
train = dm_inputdf[dm_inputdf[dm_partitionvar] == dm_partition_train_val]
X_train = train.loc[:,dm_input]
y_train = train[dm_dec_target]
lgb_train = lgb.Dataset(X_train, y_train, free_raw_data = False)

# Validation set for early stopping (optional)
valid = dm_inputdf[dm_inputdf[dm_partitionvar] == 0]
X_valid = valid.loc[:,dm_input]
y_valid = valid[dm_dec_target]
lgb_valid = lgb.Dataset(X_valid, y_valid, free_raw_data = False)

# LightGBM parameters
params = {
    'num_iterations': 60,
    'boosting_type': 'gbdt',
    'objective': 'binary',
    'metric': 'binary_logloss',
    'num_leaves': 75,
    'learning_rate': 0.05,
    'feature_fraction': 0.75,
    'bagging_fraction': 0.75,
    'bagging_freq': 0,
    'min_data_per_group': 10
}

evals_result = {}  # to record eval results for plotting

# Fit LightGBM model on training data
gbm = lgb.train(
    params,
    lgb_train,
    valid_sets = [lgb_valid, lgb_train],
    valid_names = ['valid','train'],
    early_stopping_rounds = 5,
    evals_result=evals_result
)

ax = lgb.plot_tree(gbm, tree_index=53, figsize=(25, 15), show_info=['split_gain'])
plt.savefig(dm_nodedir + '/rpt_tree.png', dpi=500)

print('Plotting feature importances...')
ax = lgb.plot_importance(gbm, max_num_features=10)
plt.savefig(dm_nodedir + '/rpt_importance.png', pad_inches=0.1)

print('Plotting split value histogram...')
ax = lgb.plot_split_value_histogram(gbm, feature='IMP_CLNO', bins='auto')
plt.savefig(dm_nodedir + '/rpt_hist1.png')

# Generate predictions and create new columns for Model Studio
tmp = gbm.predict(dm_inputdf.loc[:,dm_input])
dm_scoreddf = pd.DataFrame()
dm_scoreddf[dm_predictionvar[1]] = tmp
dm_scoreddf[dm_predictionvar[0]] = 1 - tmp
