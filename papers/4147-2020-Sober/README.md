# SAS4147-2020
##  Best Practices for Converting SAS Code to Leverage CAS
### Coding examples can be run **as is** with SAS Viya 3.5+.
### All examples are for functional testing, not performance testing.
#### **S**AS **P**rogramming **R**untime **E**nvironment (**SPRE** - [Compute server engine for SAS Viya](https://go.documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=9.4_3.5&docsetId=pgmdiff&docsetTarget=n1t409khqsu0n8n103122kk0bfzn.htm&locale=en)).
####  SAS **C**loud **A**nalytic **S**ervices (**CAS** - [In-memory engine for SAS Viya](https://go.documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=9.4_3.5&docsetId=casref&docsetTarget=p148gqjwzfm0w1n12hc60f6pfcne.htm&locale=en)).

**1. Setup.sas**
- **Required Step** 
- SPRE enabled.
- Sets the SAS macro variable &DATAPATH. 
- Copy data used in the CAS coding examples to the path defined by the macro variable &DATAPATH. 
- Macro &DATAPATH is used in the CAS coding examples.

**2. DATA.Step.Partition.and.OrderBY.sas**
- CAS enabled.
- Example of using DATA step to partition and order a CAS table.
- - Benefit: When a BY statement matches the partition and ordering, the data is immediately ready for processing by each thread. 
- - Note: **If the BY statement does not match the partition and ordering, then there is a cost that is, the BY is done on the fly** to group the data correctly on each thread.

**3. Delete.CAS.Table.sas**
- CAS enabled.
- How to delete a CAS table.
- **A good programming habit.**

**4. Display.Viya.CAS.Information.sas**
- CAS enabled.
- Provides information on your SAS Viya environment.

**5. Emulate.PROC.APPEND.sas** 
- CAS enabled. 
- [DATA step emualtion of PROC APPEND](https://blogs.sas.com/content/sgf/2017/11/20/how-to-emulate-proc-append-in-cas/).
- Note PROC APPEND is not CAS enabled and will run in SPRE.

**6. FedSQL.sas**
- CAS enabled.
- [FedSQL is CAS enabled, convert PROC SQL code into FedSQL to leverage CAS](https://blogs.sas.com/content/sgf/2019/10/22/sas-viya-how-to-emulate-proc-sql-using-cas-enabled-proc-fedsql/). 

**7. Formats.sas**
- CAS enabled.
- Ensuring SAS FORMATS are known to CAS.

**8. High.Cardinality.DATA.Step.BY.sas**
- SPRE enabled.
- High cardinality of a BY variable may run faster in SPRE. 

**9. How.to.Achive.Repeatable.Results.NODUP.sas**
- CAS enabled.
- [How to achieve repeatable results with distributed DATA step BY Groups](https://blogs.sas.com/content/sgf/2018/11/14/how-to-achieve-repeatable-results-with-distributed-data-step-by-groups/).

**10. How.to.Convert.CHARACTER.Data.Type.into.VARCHAR.Data.Type.when.Lifting.a.Table.into.CAS.sas**
- CAS enabled.
- To reduce the size of CAS tables consider converting CHARACTER data types into VARCHAR data type using PROC CASUTIL IMPORTOPTIONS VARCHARCONVERSION= statement.
- **A good programing habit.**

**11. How.to.Load.All.Datasets.from.a.CASLIB.sas**
- CAS enabled.

**12. How.to.Parallel.Load.and.Compress.a.CAS.Table.sas**
- CAS enabled.
- [How to parallel load and compress a CAS table](https://blogs.sas.com/content/sgf/2019/10/17/how-to-parallel-load-and-compress-a-sas-cloud-analytic-services-cas-table/).
 
**13. Load.SAS7BDAT.To.CAS.Table.sas**
- CAS enabled.
- Best practice to parallel load a SAS7BDAT data set into a CAS table.

**14. Load.SASHDAT.To.CAS.Table.sas**
- CAS enabled.
- Best practice to parallel load a SASHDAT table into a CAS table.

**15. ODS.Save.CAS.Table.To.CSV.File.sas**
- CAS enabled.
- Leveraging the Output Delivery System to generate a CSV file from a CAS table. 

**16. One.Level.Names.Managed.By.CAS.sas** 
- CAS enabled.
- [How to reference CAS tables using a one-level name](https://blogs.sas.com/content/sgf/2018/06/21/how-to-reference-cas-tables-using-a-one-level-name/).

**17. SAS.Viya.3.4.or.Lower.Descending.Numeric.BY.Emulation.sas** 
- CAS enabled. 
- SAS Viya 3.4 or lower.
- [How to emulate DATA step DESCENDING BY statements in SAS Cloud Analytic Services (CAS)](https://blogs.sas.com/content/sgf/2019/10/10/how-to-emulate-data-step-descending-by-statements-in-sas-cloud-analytic-services-cas/).
- **Note: SAS Viya 3.5 or higher supports DESCENDING on a DATA step BY statement with the caveat that DESCENDING is not not supported on the first variable of the BY statement**
- - Note: if there is a DESCENDING on the first variable of the BY statement the DATA step will run in SPRE.

**18. SAS.Viya.3.4.or.Lower.Emulate.PROC.SORT.NODUPKEY.sas**
- CAS enabled.
- SAS Viya 3.4 or lower.
- DATA step emulation of PROC SORT NODUPKEY is accomplished by using FIRST. (dot) processing.

**19. SAS.Viya.3.5.PROC.SORT.NODUPKEY.NOUNIKEY.sas**
- CAS enabled. 
- Requires SAS Viya 3.5+. 
- PROC SORT NODUPKEY and NOUNIKEY on CAS table examples. 

**20. Save.CAS.Table.To.SAS7BDAT.sas**
- CAS enabled.
- Best practice to save a CAS table as a SAS7BDAT table.  

**21. Save.CAS.Table.To.SASHDAT.sas**
- CAS enabled.
- Best practice to save a CAS table as a SASHDAT table. 

**22. Set.The.Active.CASLIB.sas**
- CAS enabled.
- When loading data into CAS you need to change to the active CASLIB prior to accessing tables in that CASLIB.

**23. Terminate.CAS.Session.sas**
- CAS enabled.
- How to terminate your CAS session.
- If you forget to do this do not worry, all cas sessions have a default time-out setting which is hit after a period of non activity.
- **A good programming habit.**
