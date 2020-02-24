# To install the SAS SWAT package, run either of these commands:
#   pip install swat
#   conda install -c sas-institute swat
#   pip install https://github.com/sassoftware/python-swat/releases/download/vX.X.X/python-swat-X.X.X-platform.tar.gz
# or visit:
#    https://github.com/sassoftware/python-swat

# Prior to running this program, you need to have a CAS server.


# Example of using Python to call the iml action
import swat                               # load the swat package
s = swat.CAS('your_host_name', SMPPort)   # server='myhost'; port=12345
s.loadactionset('iml')                    # load the action set

# submit your program to the action
m = s.iml(code=
            """
            c = {1, 2, 1, 3, 2, 0, 1}; /* weights */
            x = {0, 2, 3, 1, 0, 2, 2}; /* data */
            wtSum = c` * x; /* inner product (weighted sum) */
            var = var(x); /* variance of original data */
            stdX = (x-mean(x))/std(x); /* standarize data */
            var2 = var(stdX); /* variance of standardized data */
            print wtSum var var2;
            """
         )

# display the results of the action
print(m)