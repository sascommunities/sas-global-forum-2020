# Tutorial: Using SAS Macro Variable Lists to Create Dynamic Data-Driven Programs

* [exercises](./exercises) folder: 8 exercise files, ex01.sas through ex08.sas
* [solutions](./solutions) folder: 8 solution files, ex01_solution.sas through ex08_solution.sas

Software Required:  Base SAS 9.3 or higher

Data Required:      None - all exercises use SASHELP library

## Testing

Exercises 1-6 each include %PUT statements which write information to the log.  Below is what should appear in the log:

### EXERCISE 1

The MSRP for an Acura MDX is 36945.

### EXERCISE 2

The weight of an Acura MDX is 4451.

### EXERCISE 3
```
  Number of Students: 19
  Student List: Alfred Alice Barbara Carol Henry James Jane Janet Jeffrey John Joyce Judy Louise Mary
  Philip Robert Ronald Thomas William
```

### EXERCISE 4

```
  Number of Students: 19

  Student 1: Alfred
  Student 2: Alice
  Student 3: Barbara
  ...
  Student 17: Ronald
  Student 18: Thomas
  Student 19: William
```

### EXERCISE 5

```
Number of Students: 19
Student List:
Alfred~Alice~Barbara~Carol~Henry~James~Jane~Janet~Jeffrey~John~Joyce~Judy~Louise~Mary~Philip~Robert~Ronald~Thomas~William
```

### EXERCISE 6

```
Number of Students: 19

Student 1: Alfred
Student 2: Alice
Student 3: Barbara
...
Student 17: Ronald
Student 18: Thomas
Student 19: William
```

### EXERCISE 7

For Exercise 7, three external files should be written to the default user directory:

```
IBM.pdf, Intel.pdf, Microsoft.pdf
```

### EXERCISE 8

For Exercise 8, three new data sets should be created in the WORK library:

```
CARS_ASIA
CARS_EUROPE
CARS_USA
```

## Support contact

```
Instructor: Josh Horstman
Email:      jmhorstman@gmail.com
```