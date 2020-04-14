# Your Data Will Go On: Practice for Character Data Migration                                                 

This paper introduces the practice of SAS character data migration.  If you have problems in migrating your data from one SAS environment to another, you may find the solution here. This project includes the examples used in the paper, and a PPT to help you understand the general content of the paper

## Examples

All the examples are in the *examples* folder. The examples can be run as is with SAS Viya 3.5+. If a file name contains the suffix *latin1*, the SAS client encoding should be latin1 or wlatin1. Otherwise, the client encoding  should be UTF-8. Below are the descriptions of the examples.

**1_gen_data_latin1.sas**

This file generates the data sets and transport files used by other examples. All the characters are encoded in wlatin1 (Windows-1252). It stimulates the existing data which is a candidate to be moved to another environment such as UTF-8.

**2_check_encoding.sas**

This file checks if the input data set encoding is compatible with current SAS session encoding. 

**3_expand_use_cvp.sas**

The file demonstrates how to use the CVP engine to expand character variables and convert CHAR variables to VARCHAR. Run this case in a UTF-8 environment.

**4_expand_in_cas_latin1.sas**

This file shows the usage of the CAS options to expand character variables. Please note that these options only take effect when SAS client encoding is not UTF-8.

**5_data_connector.sas**

This file uses CAS data connector to expand character variables and convert CHAR variables to VARCHAR.

**6_cimport.sas**

This case uses the *extendvar* option to expand character variables during cimporting.

**7_kpropdata.sas**

This file shows how to use kpropdata function to handle unprintable characters.

## Additional information

Find the full paper online with the [SAS Global Forum proceedings](https://www.sas.com/en_us/events/sas-global-forum/program/proceedings.html).


