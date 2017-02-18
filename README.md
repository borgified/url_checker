Looks for broken urls in vhf/free-programming-books

1. pulls down a clone of vhf/free-programming-books (or fast-forwards if already exists)
2. uses URI::Find to pick out urls each file (more than one url per line is OK)
3. test for broken urls using multiple methods to reduce false negatives
  1. HEAD request
  2. GET request
  3. using curl

results are displayed at STDOUT


There are *THREE* ways to run this.

1. run pre-built [docker](https://docs.docker.com/engine/getstarted/step_one/#/step-1-get-docker) container from dockerhub `./prun`
2. build [docker](https://docs.docker.com/engine/getstarted/step_one/#/step-1-get-docker) container locally and run it `./drun`
3. run as a perl script (you need to install dependencies) `./run`
