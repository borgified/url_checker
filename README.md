TODO

- [x] This version is meant to be run as an app in @openshift.
- [x] The plan is to run it once a day as a cron job.
- [x] It will look at all free-programming-book-*.md files in https://github.com/vhf/free-programming-books and check each one for bad urls.
- [x] Assumes a line has maximum of (1) url.
- [ ] If a bad url is found, create a pull request automatically.
- [ ] After processing a file, it will regenerate the table of contents using http://doctoc.herokuapp.com.


Future

- [ ] sort urls in alphabetical order
- [ ] store url check results in a database to get a historical view
- [ ] save checksum of http payload after GET, create issue if checksum is found to be inconsistent


