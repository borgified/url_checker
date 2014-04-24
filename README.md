Looks for broken urls in vhf/free-programming-books

1. pulls down a clone of vhf/free-programming-books (or fast-forwards if already exists)
2. uses URI::Find to pick out urls each file (more than one url per line is OK)
3. test for broken urls using multiple methods to reduce false negatives
  1. HEAD request
  2. GET request
  3. using curl
  
results are displayed at STDOUT



to run this script, clone the repo, then type ./run
