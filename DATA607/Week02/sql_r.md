---
title: "SQL and R"
author: "Jai Jeffryes"
date: "9/5/2019"
output:
  html_document:
    df_print: paged
    keep_md: true
---


```r
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_knit$set(root.dir = "./../..")
```

## Introductory note
This assignment integrates with a MySQL database. Besides satisfying the requirements of the assignment, I like to record what I learned along the way. It helps me remember, and I also use my assignments for reference. I'll let you know when the assignment starts, in case you want to skip down the page.

Here we go.

## MySQL
I'm a SQL Server DBA. I wanted to do this assignment in MySQL so I would have a chance to work with it for the first time. A few things I got out of it.

- It looks like maybe MySQL is not a multi-database server. When I created the database, the IDE called it a "schema." I would like to understand the security and access around that better.
- The keyboard shortcut for execution is CTRL-Return.
- IDENTITY comes from SQL Server, not ANSI. Guess I shouldn't be surprised because Oracle, too, has its own approach, SEQUENCE, which in Oracle is a database object. Do this in MySQL using the keyword AUTO_INCREMENT.
- Terminate commands in a script with a semi-colon. I've rebelled against doing this for over a decade in SQL Server. Suck it up, dude, and stop your whining about how it makes your SQL look like Pascal.

## Setting up R
A perfect example of why I like

a. virtual machines, and
b. Ubuntu

With a virtual machine (I use VirtualBox), I can snapshot my OS before messing around with installations and configuration. Any regrets about the changes, pitch 'em.

Ubuntu I like because I can make a new VM for everything I want to do while sticking with one fundamental toolset that I use better and better.

### Packages
I wanted to try out the approach from *Automated Data Collection with R* that relies on the `DBI` package. Next time, I'll try `RODBC`, so I can see how to create an ODBC connection in Linux.

I already had `DBI`, but now I needed to install `RMySQL`. When I tried, I got this error.

```
------------------------- ANTICONF ERROR ---------------------------
Configuration failed because no mysql client library was found. Try installing:
 * deb: libmariadbclient-dev | libmariadb-client-lgpl-dev (Debian, Ubuntu)

...

If you already have a mysql client library installed, verify that either
mariadb_config or mysql_config is on your PATH.
```

I wanted to look for those libraries to see if my installation of MySQL simply neglected to put them on my path. I know how to do that in Ubuntu! I have a repo with sample code in it, which I call `hammer`. I looked up my Ubuntu file and found the command for listing installed Linux packages.

```
dpkg --list
```

And since I've been working on `grep`, I could pipe the list to `grep` to focus my search.

```
dpkg --list | grep -E "maria|mysql"
```

Nope, the client libraries aren't there. Go get 'em, Tiger.

```
sudo -i
apt-get install libmariadbclient-dev
apt-get install libmariadb-client-lgpl-dev
```

Now my installation of `RMySQL` worked. Yay.

## Assignment starts here
Load package. `DBI` comes along, too, for free.

```r
library(RMySQL)
```

```
## Loading required package: DBI
```

### Connect
Now the pain started. Thought I followed the `RMySQL` package documentation, it didn't appear to work straight away. Newsflash: the computer is never the jerk. More in a sec.

```
Failed to connect to database: Error: Can't connect to local MySQL server through socket '/tmp/mysql.sock'
```

This command verified the server is running.
```
# mysqladmin -u root -p status
```

With this output:
```
Uptime: 10379  Threads: 4  Questions: 474  Slow queries: 0  Opens: 271  Flush tables: 3  Open tables: 191  Queries per second avg: 0.045
```

### Connection lessons learned
Working with `dbCanConnect()`, I determined the following.

- The host cannot be "localhost". It must be "127.0.0.1".
  - Use `ifconfig` to verify your loopback IP address.
- The MySQL login "root" uses a caching SHA2 password. I don't know yet how to authenticate like that, or change the authentication method to Standard (if I even wanted to), so I created a new user with a weak password and granted permissions only to `SELECT`.


```r
con <- dbConnect(
	drv = MySQL(),
	host = "127.0.0.1",
	user = "jairpt",
	password = "a",
	dbname = "moviesurv")
```

## Get survey report
I designed my tables for the movie survey using a few entities with joins. I wanted to illustrate that while a source system might be transactional, retrieval for analysis should flatten the data set. The query does that and saves it to a tidy data set.


```r
sql <- "
select	m.title,
		rsd.name,
        rss.response
from	response rss
join	movie m
on		rss.movie_id = m.movie_id
join	respondent rsd
on		rss.respondent_id = rsd.respondent_id;"

movierpt <- dbGetQuery(con, sql)

# The report is a data frame.
str(movierpt)
```

```
## 'data.frame':	30 obs. of  3 variables:
##  $ title   : chr  "Once Upon a Time... in Hollywood" "Once Upon a Time... in Hollywood" "Once Upon a Time... in Hollywood" "Once Upon a Time... in Hollywood" ...
##  $ name    : chr  "Jai" "Jan" "Bob" "Joe" ...
##  $ response: int  3 5 NA NA 4 5 5 4 4 NA ...
```

```r
# View it
print(movierpt)
```

```
##                               title name response
## 1  Once Upon a Time... in Hollywood  Jai        3
## 2  Once Upon a Time... in Hollywood  Jan        5
## 3  Once Upon a Time... in Hollywood  Bob       NA
## 4  Once Upon a Time... in Hollywood  Joe       NA
## 5  Once Upon a Time... in Hollywood  Lee        4
## 6                        Rocket Man  Jai        5
## 7                        Rocket Man  Jan        5
## 8                        Rocket Man  Bob        4
## 9                        Rocket Man  Joe        4
## 10                       Rocket Man  Lee       NA
## 11                       Green Book  Jai        4
## 12                       Green Book  Jan        5
## 13                       Green Book  Bob        4
## 14                       Green Book  Joe        3
## 15                       Green Book  Lee        3
## 16                Bohemian Rhapsody  Jai       NA
## 17                Bohemian Rhapsody  Jan        5
## 18                Bohemian Rhapsody  Bob        4
## 19                Bohemian Rhapsody  Joe        4
## 20                Bohemian Rhapsody  Lee        3
## 21                        Apollo 11  Jai        4
## 22                        Apollo 11  Jan        2
## 23                        Apollo 11  Bob        3
## 24                        Apollo 11  Joe        3
## 25                        Apollo 11  Lee        4
## 26          The Art of Self-Defense  Jai        4
## 27          The Art of Self-Defense  Jan        1
## 28          The Art of Self-Defense  Bob        5
## 29          The Art of Self-Defense  Joe       NA
## 30          The Art of Self-Defense  Lee        4
```


