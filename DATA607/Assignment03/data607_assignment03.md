---
title: "DATA607: Assignment 3, Regular Expressions"
author: "Jai Jeffryes"
date: "9/12/2019"
output:
  html_document:
    keep_md: yes
---



## Character Processing, Character Building
**Assignment**

- Problems 3 and 4 from chapter 8 of *Automated Data Collection in R*.
- Problem 9 is extra credit. *(Not included)*

### Contents
- [Problem 3](#problem-3)
  - [3a](#problem-3a)
  - [3b](#problem-3b)
  - [3c](#problem-3c)
- [Problem 4](#problem-4)
- [How I got there](#how-i-got-there)
- [Test cases](#test-cases). A few tests that got me started.
- [Lessons learned](#lessons-learned)
  - [Character classes](#character-classes)
  - [Escape from Escape, *AKA* Code That Writes Code](#escape-from-escape-aka-code-that-writes-code)
  - [Capturing groups](#capturing-groups)
  - [Negative look aheads](#negative-look-aheads)
  - [Markdown internal links](#markdown-internal-links)
- [Conclusions](#conclusions)
- [Development plan](#development-plan)

### Problem 3
Copy the introductory example. The vector name stores the extracted names.


```r
library(stringr)

raw.data <-"555-1239Moe Szyslak(636) 555-0113Burns, C. Montgomery555-6542Rev. Timothy Lovejoy555 8904Ned Flanders636-555-3226Simpson, Homer5553642Dr. Julius Hibbert"

# Extract information
name <- unlist(str_extract_all(raw.data, "[[:alpha:]., ]{2,}"))
name
```

```
## [1] "Moe Szyslak"          "Burns, C. Montgomery" "Rev. Timothy Lovejoy"
## [4] "Ned Flanders"         "Simpson, Homer"       "Dr. Julius Hibbert"
```

#### Problem 3a
Use the tools of this chapter to rearrange the vector so that all elements conform to the standard first_name last_name.


```r
# Identify  elements for correction.
has_comma <- str_detect(name, ",")

# Pick off last name.
last_name <- str_extract(name, "^[[:alpha:]. ]+")
last_name[!has_comma] <- NA

# Pick off first name.
first_name <- str_match(name, "(, )(.+)")
first_name <- first_name[,3]

# Swap last and first names.
name_scrub <- name
name_scrub[has_comma] <- str_c(first_name[has_comma], " ", last_name[has_comma])

name_scrub
```

```
## [1] "Moe Szyslak"          "C. Montgomery Burns"  "Rev. Timothy Lovejoy"
## [4] "Ned Flanders"         "Homer Simpson"        "Dr. Julius Hibbert"
```

Conclusion: This satisfies the assignment, but I explore the case of a name suffix, like ", Jr.," below in [Negative look ahead](#negative-look-ahead).

#### Problem 3b
Construct a logical vector indicating whether a character has a title (i.e., Rev. and Dr.).


```r
# Use a pick list of titles rather than detecting a pattern based on length. Analysis appears later
# in the notebook.
# Maintain this list. Note: The format is human readable.
title <- c("Mr.", "Mrs.", "Ms.", "Miss", "Dr.", "Rev.", "Hon.", "M.", "Master")

# Prepare regular expression.
title_pat <- paste(title, collapse = "|")               # Connect titles with logical OR.
title_pat <- toupper(title_pat)                         # Case insensitive.
title_pat <- str_replace_all(title_pat, "\\.", "\\\\.") # Escape periods.
title_pat <- str_c("^(", title_pat, ")")                # Assemble the RegEx.
title_pat                                               # Review the pattern.
```

```
## [1] "^(MR\\.|MRS\\.|MS\\.|MISS|DR\\.|REV\\.|HON\\.|M\\.|MASTER)"
```

```r
has_title <- str_detect(string = toupper(name), pattern = (title_pat))
has_title
```

```
## [1] FALSE FALSE  TRUE FALSE FALSE  TRUE
```

Names with titles:

Rev. Timothy Lovejoy, Dr. Julius Hibbert

Names without titles:

Moe Szyslak, C. Montgomery Burns, Ned Flanders, Homer Simpson

#### Problem 3c
Construct a logical vector indicating whether a character has a second name.


```r
# Strip titles before counting name parts.
# We still have the title variable. 
# Prepare regular expression.
title_strip_pat <- paste(title, collapse = "|")                     # Connect titles with logical OR.
title_strip_pat <- toupper(title_strip_pat)                         # Case insensitive.
title_strip_pat <- str_replace_all(title_strip_pat, "\\.", "\\\\.") # Escape periods.
title_strip_pat <- str_c("(", title_strip_pat, ")(.+)")             # Assemble the RegEx.
title_strip_pat                                                     # Review the pattern.
```

```
## [1] "(MR\\.|MRS\\.|MS\\.|MISS|DR\\.|REV\\.|HON\\.|M\\.|MASTER)(.+)"
```

```r
# Strip titles.
name_title_strip <- str_match(toupper(name), title_strip_pat)[,3]   # Reference capture group for target match.
name_title_strip <- str_trim(name_title_strip)                      # Could nest functions, but I don't as a rule
                                                                    # for maintainability.
is_replace <- !is.na(name_title_strip)                              # Logical vector indicating replacements.

# Merge names.
name_scrub_no_title <- name_scrub
name_scrub_no_title[is_replace] <- name_title_strip[is_replace]     # Replace just the ones with titles.

# Split names.
name_scrub_no_title_split <- str_split(name_scrub_no_title, " ")
# Here's how they look before counting name parts.
name_scrub_no_title_split
```

```
## [[1]]
## [1] "Moe"     "Szyslak"
## 
## [[2]]
## [1] "C."         "Montgomery" "Burns"     
## 
## [[3]]
## [1] "TIMOTHY" "LOVEJOY"
## 
## [[4]]
## [1] "Ned"      "Flanders"
## 
## [[5]]
## [1] "Homer"   "Simpson"
## 
## [[6]]
## [1] "JULIUS"  "HIBBERT"
```

```r
# Count words.
name_word_count <- sapply(name_scrub_no_title_split, length)
name_word_count
```

```
## [1] 2 3 2 2 2 2
```

```r
# Logical vector for second name.
has_second_name <- name_word_count > 2
has_second_name
```

```
## [1] FALSE  TRUE FALSE FALSE FALSE FALSE
```

Names with second name:

C. Montgomery Burns

Names without second name:

Moe Szyslak, Rev. Timothy Lovejoy, Ned Flanders, Homer Simpson, Dr. Julius Hibbert

### Problem 4
Describe the types of strings that conform to the following regular expressions and construct an example that is matched by the regular expression.

a. `[0-9]+\\$`: Any number of numeric digits, followed by a dollar sign. The symbol "$" is not an EOL anchor here.

```r
pat <- "[0-9]+\\$"
a_string <- "abcdef 198765$ morestuff"
str_extract(a_string, pat)
```

```
## [1] "198765$"
```
b. `\\b[a-z]{1,4}\\b`: A word of length 1-4 characters.

```r
pat <- "\\b[a-z]{1,4}\\b"
a_string <- "Really lengthy words, (numbers excluded: 123), match now"
str_extract(a_string, pat)
```

```
## [1] "now"
```

c. `.*?\\.txt$`: The name of a text file. Any number of characters, which are optional followed by a period and a ".txt" file extension anchored to the end of the string. There is a benign error in the pattern. Since the quantifier "*" matches zero or more times, the quantifier "?", indicating optionality, is unnecessary here, which I demonstrate in my examples.

```r
pat <- ".*?\\.txt$"
a_string <- "mairzydoats.txt"
str_extract(a_string, pat)
```

```
## [1] "mairzydoats.txt"
```

```r
a_string <- ".txt"
str_extract(a_string, pat)
```

```
## [1] ".txt"
```

```r
# Alternate pattern, eliminating unnecessary "?" quantifier. The matches are the same.
pat <- ".*\\.txt$"
a_string <- "mairzydoats.txt"
str_extract(a_string, pat)
```

```
## [1] "mairzydoats.txt"
```

```r
a_string <- ".txt"
str_extract(a_string, pat)
```

```
## [1] ".txt"
```
d. `\\d{2}/\\d{2}/\\d{4}`: A date, whose format requires exactly two digits in the month and the day positions and four for the year. 1/1/19 would not match.

```r
pat <- "\\d{2}/\\d{2}/\\d{4}"
a_string <- "09/12/2019"
str_extract(a_string, pat)
```

```
## [1] "09/12/2019"
```

```r
# This fails to match because of the single digit in the month position.
a_string <- "9/12/2019"
str_extract(a_string, pat)
```

```
## [1] NA
```

e. `<(.+?)>.+?</\\1>`: A pair of XML tags enclosing an element. The closing tag employs a back reference.

```r
pat <- "<(.+?)>.+?</\\1>"
a_string <- "<language>Ferengi</language>"
str_extract(a_string, pat)
```

```
## [1] "<language>Ferengi</language>"
```

## How I got there
Regular expressions and I have always rolled like this.

![](img/wrestlers.jpg)

### There has to be better way
![](img/albert.jpg)


I liked this quote, often attributed to Albert Einstein.

> If I had only one hour to save the world, I would spend fifty-five minutes defining the problem, and only five minutes finding the solution.

![](img/bowshot.jpg)


And Dr. Catlin's admonition was a shot across the bow.

> Master your tools to earn a place at the stakeholder table.

I have complained about Regular Expressions and made excuses for long enough. Time to let a new idea in! This is why I'm taking these dang courses, after all, and this is why this assignment came to me.

Time to commit and come to the table.

### A new deal
I think my mental block with RegEx's stems from spending insufficient time up front asking questions about what I'm looking for. Write it down! Don't be a hero and go straight for the code. Get down as many questions first. Isn't that Software Design 101, after all?

Then embrace the RegEx instead of wrestling with it. Here goes.

### Ask questions

#### 3a
- Find the unconforming names.
  - How? In this case, by the presence of a comma.
  - What if there is a suffix, like ", Jr."? You wouldn't want to identify that as unconforming because of its comma. How could you differentiate that one? How about count the words before the comma. If there is one word, then it must be a last name.
  - No, what about my wife? Her surname is two words. You get this element: "La Salle, Jan." Word counting on either side of the comma doesn't work.
  - It would have to be an explicit list of suffixes: Jr., Sr., Ph. D., Esq.
  - There would have to be some flexibility of the suffix format. With or without periods or spaces. How about case insensitive, too. Jr, SR, PhD.
  - This suffix match must be complete. You can't just find the suffix in the right side of the comma. Anchor it, front and back. It must be the only string on the right side of the delimiter.
  - Is that valid? Could there be a suffix and something else after a comma? Is there such a name as "Thurston Howell III, Jr."? No, but he could be an academic. "Thurston Howell, Sr. Ph.D".
  - And if he's an academic and has some honorary degrees, too, well there would be more than one comma. "Thurston Howel, Jr., Ph. D., D.D". Ah! Make an additional vector with extra test cases.
- How do you pick off first names.
  - The requirements are already getting a little grey. One of the "first names" is really a first initial and a middle name.
- How do you pick off last names.
- How do you swap the pieces by position.

**Approach**

`str_split` finds the names containing commas. It returns a list that even leaves intact the names that lack a comma. However, I didn't know how I'd swap the positions of the list members that needed it. I want to support a variable number of splits, e.g. "Downey, Robert, Jr.". Therefore, go with an approach that picks off the parts and then concatenates them.

#### 3b
- What defines a title?
  - It appears at the beginning of the name.
  - If the first and last name are reversed, I assume it would appear before the first name, not after. Post-fixed strings would be appended degrees. I.e. Dr. Anatole Hibbert, D.D. reversed would be, "Hibbert, Dr. Anatole, D.D."
  - Is a title distinguishable from an initial? In this assignment yes, by length. However, more generally, no. The French "Monsier", is abbreviated "M.". Supporting that would require defining a pick list of known titles. That list should be in a variable, for maintainability.
  - Titles are usually abbreviated, so you can look for a period. On the other hand, they can be spelled out, in which case, you would need to include them in the picklist of abbreviated titles. This is where you need to know your data. You have to call up the engineer who has the specification for generating this data. Does it come from a web application? Is there data validation on the front end? Is it user input? Does the user choose from a combo box or type free form? Free form data entry of titles is pretty rare, but maybe this is a data set scraped from old newspaper articles. Anything could be in a data source like that. If this were a real application, you'd have to go find out. That could take you a week. Then you go ahead and write the Regular Expression. Like Einstein says, once you know what to do, that part might just take you five minutes.

#### 3c
- What is a second name? Growing up, sometimes people described surname as second name. Since every name in the demonstration has a last name, a vector of all TRUE values would be trivial. I assume the authors' intention is middle name.
- Second name therefore requires a minimum of three words in the name.
- The words, however, must not include titles. Dr. Julius Hibbert has three words in his name, but no second name.
- Suffixes don't count, though there are none in the sample data. Robert Downey, Jr. has no second name. Thurston Howell III has no second name.
- My wife is a deal breaker. Her last name, La Salle, has two words. With Regular Expressions alone, there would be no way to discern that Jan La Salle has no second name, while Thockmorton P. Guildersleeve does. Regular Expressions (and any programming language, really) can only derive so much semantic meaning from unstructured text. It's possible to find an answer for the data provided in this assignment. However, Regular Expressions would be unable to support a requirement of identifying name parts as described in this exercise.

### Test cases
All of those questions suggest it's about time for some test cases. I could go a lot further here, but a little positive and negative testing got me moving. I'm a big fan of Test Driven Development anyway.

#### Positive tests
Names that are reversed and must be flipped.

1. Case with a suffix.
1. Case with two words in the surname.
1. Case with a suffix and a degree.
1. Case with a title and no suffix.

Expected results: All cases match.


```r
name_test_positive <- c("Downey, Robert, Jr.",
                        "La Salle, Jan",
                        "Jones, Robert, Jr., Ph. D.",
                        "Hibbert, Dr. Anatole")

# Pattern using word edge character class short cut: \<
# Expected results: Return everything after the first comma, beginning from the first complete word.
name_test_positive_t1 <- str_extract(name_test_positive, ",.+")
str_extract(name_test_positive_t1, "\\<.+")
```

```
## [1] NA NA NA NA
```

Actual results: Returns NA.

Conclusion: Failure.


```r
# Pattern using word boundary character class short cut, \b
# Expected results: Return everything after the first comma, beginning from the first complete word.
name_test_positive_t2 <- str_extract(name_test_positive, ",.+")
str_extract(name_test_positive_t2, "\\b.+")
```

```
## [1] "Robert, Jr."         "Jan"                 "Robert, Jr., Ph. D."
## [4] "Dr. Anatole"
```

Actual results: Returns first name to the end, trimming leading comma and space.

Conclusion: Success.

#### Negative tests
Names ordered first name and last name. However, they include a trailing comma and suffix.

Expected results: No match. Names are not detected for reversal.

```r
name_test_negative <- c("Robert Downey, Jr.", "Robert Jones, Jr., Ph. D.")

# Split on comma.
# Could split on comma and space, but let's trim separately instead. Would support multiple spaces in names.
name_test_negative_split <- str_split(name_test_negative, ",")
name_test_negative_split <- lapply(name_test_negative_split, str_trim)
name_test_negative_split
```

```
## [[1]]
## [1] "Robert Downey" "Jr."          
## 
## [[2]]
## [1] "Robert Jones" "Jr."          "Ph. D."
```

Actual results: Match.

Conclusion: Failure. Names with suffixes appear as false positives. Bug fixed in [Lessons learned, Negative look ahead](#negative-look-ahead).

### Lessons learned
#### Character classes
- The character classes for word edges (`\<` and `\>`) as identified in *Automated Data Collection in R*, p. 208 do not work. (cf. [Postive tests](###positive-tests). ) The book is either mistaken or the symbols are unsupported in my environment.
- The word boundary short cut (`\b`) does work.

#### Escape from Escape, *AKA* Code That Writes Code
I love writing code that writes code. Now I see that I can apply this to Regular Expressions. My database team found it helpful to write SQL that added escape characters for dynamic SQL. The strategy amounted to macro expansion. We coded a stub ("^") in place of single-quotes in our dynamic SQL and a function expanded them. So much easier than trying to keep your head straight with nested escapes.

I can do the same thing in Regular Expressions! In [Problem 3b](#problem-3b), I needed a pick list of titles. I made the list human readable so a programmer could maintain it. Then code delimits the list with OR operators, escapes any periods, and assembles the complete Regular Expression. If you have to go back and maintain the pick list, you don't have to dig into Regular Expression and figure out all over again how to do it.

#### Capturing groups
You can separate what you *don't* want from what you *do* want by using capturing groups and then vectorizing them with `str_match()`. If the match is unexpected in every element, then this is a more elegant alternative than `str_extract()` or `str_split()`. Here are the three alternatives for finding first names, with annotations.


```r
name
```

```
## [1] "Moe Szyslak"          "Burns, C. Montgomery" "Rev. Timothy Lovejoy"
## [4] "Ned Flanders"         "Simpson, Homer"       "Dr. Julius Hibbert"
```

```r
# Using str_extract().
# Need to identify which elements to operate on.
has_comma <- str_detect(name, ",")

first_name <- str_extract(name, ", .+")
first_name
```

```
## [1] NA                ", C. Montgomery" NA                NA               
## [5] ", Homer"         NA
```

```r
# Good that it doesn't match on the elements not to be operated on. However, the matches still need
# stripping of the delimiter.
first_name <- str_extract(first_name, "\\b.+")
first_name
```

```
## [1] NA              "C. Montgomery" NA              NA             
## [5] "Homer"         NA
```

```r
# The full solution still requires picking off the last name, but we can demonstrate replacing the
# names that need a first name swap. Reference the logical vector that identifies scrubbing targets.
name_scrub_wip <- name
name_scrub_wip[has_comma] <- first_name[has_comma]
name_scrub_wip
```

```
## [1] "Moe Szyslak"          "C. Montgomery"        "Rev. Timothy Lovejoy"
## [4] "Ned Flanders"         "Homer"                "Dr. Julius Hibbert"
```

```r
# Using str_split().
# Need to identify which elements to operate on.
has_comma <- str_detect(name, ",")

first_name <- str_split(name, ", ")
first_name
```

```
## [[1]]
## [1] "Moe Szyslak"
## 
## [[2]]
## [1] "Burns"         "C. Montgomery"
## 
## [[3]]
## [1] "Rev. Timothy Lovejoy"
## 
## [[4]]
## [1] "Ned Flanders"
## 
## [[5]]
## [1] "Simpson" "Homer"  
## 
## [[6]]
## [1] "Dr. Julius Hibbert"
```

```r
# The name parts are fully split, requiring no further trimming. This is an improvement over 
# str_extract(). The names with no delimiter are populated with a single vector element. We need to
# access the list items that have a second vector element and then collapse the list into a vector.
first_name <- unlist(lapply(first_name, function(x) x[2]))
first_name
```

```
## [1] NA              "C. Montgomery" NA              NA             
## [5] "Homer"         NA
```

```r
# The str_extract() solution got us to this point, too. Replacing the target elements is the same. We
# need the logical vector identifying the targets.
name_scrub_wip <- name
name_scrub_wip[has_comma] <- first_name[has_comma]
name_scrub_wip
```

```
## [1] "Moe Szyslak"          "C. Montgomery"        "Rev. Timothy Lovejoy"
## [4] "Ned Flanders"         "Homer"                "Dr. Julius Hibbert"
```

```r
# Using capturing groups and str_match().
# This is the most elegant solution of these three alternatives and the one chosen for the assignment.
# We still need to identify the target elements.
has_comma <- str_detect(name, ",")

# We use the same pattern as we did with str_extract(), but separate and capture each piece.
first_name <- str_match(name, "(, )(.+)")
first_name
```

```
##      [,1]              [,2] [,3]           
## [1,] NA                NA   NA             
## [2,] ", C. Montgomery" ", " "C. Montgomery"
## [3,] NA                NA   NA             
## [4,] NA                NA   NA             
## [5,] ", Homer"         ", " "Homer"        
## [6,] NA                NA   NA
```

```r
# Functionally, we're in the same place we were with str_split. However, referencing the piece we
# want is simpler. We eliminated two steps. We don't need lapply() in order to reference the parts
# we want, and we don't need to collapse the list. We can reference the capturing group we want.
first_name <- first_name[,3]

# Finally, replace the targets, as in the other solutions.
name_scrub_wip <- name
name_scrub_wip[has_comma] <- first_name[has_comma]
name_scrub_wip
```

```
## [1] "Moe Szyslak"          "C. Montgomery"        "Rev. Timothy Lovejoy"
## [4] "Ned Flanders"         "Homer"                "Dr. Julius Hibbert"
```

#### Negative look aheads
In [Problem 3a](#problem-3a), we identified names whose format was "LastName, FirstName" by detecting the comma. However, the name "Morton Downey, Jr.," though in the specified format of "FirstName Lastname", would raise a false positive for format correction. Presence of a comma indicates a leading last name only if the comma is not directly followed by a name suffix, like "Jr." or "Ph. D."

We want to match on a comma, while prohibiting a trailing suffix. This is achievable with a negative look head.


```r
# Set up test data.
name_incl_suffix <- c(name, "Morton Downey, Jr.", "Dr. Anatole Hibbert, Ph. D.")

# Original solution fails. False positives indicated for swapping first and last names.
has_comma <- str_detect(name_incl_suffix, ",")
name_incl_suffix[has_comma]
```

```
## [1] "Burns, C. Montgomery"        "Simpson, Homer"             
## [3] "Morton Downey, Jr."          "Dr. Anatole Hibbert, Ph. D."
```

```r
# Solution employing negative look ahead.
# Build pick list of suffixes.
suffix <- c("Jr.", "Ph. D.")

# Prepare regular expression.
suffix_pat <- paste(suffix, collapse = "|")               # Connect titles with logical OR.
suffix_pat <- toupper(suffix_pat)                         # Case insensitive.
suffix_pat <- str_replace_all(suffix_pat, "\\.", "\\\\.") # Escape periods.
# Negative look ahead example: ",\\s(?!Jr\\.)"
suffix_pat <- str_c(",\\s(?!", suffix_pat, ")")           # Assemble the RegEx.
suffix_pat                                                # Review the pattern.
```

```
## [1] ",\\s(?!JR\\.|PH\\. D\\.)"
```

```r
is_swap <- str_detect(string = toupper(name_incl_suffix), pattern = (suffix_pat))
# This is correct now.
is_swap
```

```
## [1] FALSE  TRUE FALSE FALSE  TRUE FALSE FALSE FALSE
```

```r
# Names to be swapped
name_incl_suffix[is_swap]
```

```
## [1] "Burns, C. Montgomery" "Simpson, Homer"
```

```r
# Names not to be swapped
name_incl_suffix[!is_swap]
```

```
## [1] "Moe Szyslak"                 "Rev. Timothy Lovejoy"       
## [3] "Ned Flanders"                "Dr. Julius Hibbert"         
## [5] "Morton Downey, Jr."          "Dr. Anatole Hibbert, Ph. D."
```


#### Markdown internal links
R Markdown generates internal links for headings. The format for the link portion of the tag is:

- Single "#" character, no matter what level the heading is.
- Text in lower case.
- Replace spaces with hyphens.

Therefore, the link to this heading would be `[Description](#markdown-internal-links)`.

**N.B.**: This does not work for headings that begin with a numeral. To build a table of contents for this document, I had to change my problem sub-headings from e.g. `#### 3a` to `#### Problem 3a`.

### Conclusions
- Documenting my questions about the structure of the text data helped me put together a plan for parsing it.
- The `stringr` package is easier to grasp and use than base R string processing. It helps that the funtion protocols are consistent. Even `str_c()` (from `stringr`) is one less character to type than `paste0()` (from base R). As Steven Wright said: "The abbreviation for 'June' is 'JUN'... man, you gotta be in a hurry." 

![](img/steven.jpg)

### Development plan
These texts helped me. Stick with them and complete all the exercises.

- *Automated Data Collection with R* by Simon Munzert, et. al. Chapter 8.
- *Handling and Processing Strings in R* by [Gaston Sanchez](https://www.regular-expressions.info/reference.html). Oriented towards base R, but that got me on the road for clarifying what I want, in particular capturing groups. Review all the string processing, not just Regular Expressions.
  - I shouldn't have looked at his site. There's a book there about linear algebra, too, and I'm always looking for applications. With the rise of discrete processing, linear algebra is even more relevant than calculus in the 21st century. Another seductive time sink...
- [Regular Expressions Info](https://www.regular-expressions.info/reference.html). I always found this website pretty opaque, but parts of it now seem more friendly. Keep going back to note what has become more familiar and to suggest next steps.

#### Teach!
Explaining my lessons learned here is a start. Now haunt [StackOverflow](https://stackoverflow.com). My best answer there, which got me started earning reputation points, included utilization of `grep`. It was about an assignment in a popular online R course and has gotten 4000 views.

[Using R, getting a “Can't bind data because some arguments have the same name” using dplyr:select](https://stackoverflow.com/questions/54932063/using-r-getting-a-cant-bind-data-because-some-arguments-have-the-same-name-u)

Watch the `regex` tag on StackOverflow. Make it a goal to gain reputation points by answering Regular Expression questions.
