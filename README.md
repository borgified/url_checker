Looks for broken urls in vhf/free-programming-books


if a link is broken, create an issue
include original committer, bad url and which lang (add as label)


todo

* detect if the same issue has already been created previously (and avoid creating another)

> tentative solution: look for open issues with "url_checker" label, avoid creating issues for urls that have already been reported. if a reported url is a false positive (ie link is not broken), just leave the issue open so that it wont be reported again.


* figure out how to run this in openshift
