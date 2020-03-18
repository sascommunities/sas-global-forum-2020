# Incorporating Prior Information into Your Model Using Bayesian Methods in SAS Econometrics

## Files

1. autoprior.pdf : PDF of slides from the presentation
2. autoprior_run.sas : SAS script for running all of the code for the presentation. Calls the next few scripts below.
3. trucksales_data.sas : SAS script for generating the dataset used for the example.
4. autoprior_linear.sas : SAS script for creating the model and class statements, and the prior distribution dataset.
5. autoprior_priorstmt.sas : SAS script for creating the prior statements.

See comments in the SAS files for documentation.

## Additional information
See also:
1. [SAS43110-2020 - Incorporating Auxiliary Information into Your Model Using Bayesian Methods in SAS® Econometrics](https://github.com/sascommunities/sas-global-forum-2020/tree/master/papers/4311-2020-Simpson)
   Paper describing how to select priors in Bayesian inference. Both default priors, and informative priors are considered.

2. [SD313 - From Posterior to Post Processing: Getting More from Your Bayesian Model](https://github.com/sascommunities/sas-global-forum-2020/tree/master/demos/SD313-Simpson-PostProcess)
   Super Demo showing how to use the posterior predictive distribution to do inference on quantities that depend on the model, but are not simply a parameter in the model. For example, predicting how high sales would be in several potential locations for a new dealership.
   
## Support contact(s)

Matt Simpson: Matt.Simpson@sas.com
