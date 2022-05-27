library(stringr)

# this should work for any search query on Bayesian Analysis
# can't get urls bc my scraping is kinda jank
bayessearchbaseurl = "https://projecteuclid.org/Search?term=sequential%20monte%20carlo&pageSize="
maxsearchlen = 200
searchurl = paste0(bayessearchbaseurl, maxsearchlen)
download.file(searchurl, "bayessearch.txt")

bayessearch = readLines(con = "bayessearch.txt")

longmatch = 'DisplayResults\\(\\[\\{'
longnum = which(str_detect(bayessearch, longmatch))
longboi = bayessearch[longnum]

# setting up regex stuff
abstractreg = '"Abstract":(.*?),"Access":'
titlereg = '"HTMLTitle":(.*?),"VideoID"'
keywordreg = '"Keywords":(.*?),"ModifiedOn"'

abstracts = str_match_all(longboi, abstractreg)[[1]][,2]
titles = str_match_all(longboi, titlereg)[[1]][,2]
keywords = str_match_all(longboi, keywordreg)[[1]][,2]

# not sure how useful keywords and titles are but figured I'd grab them too
keywords = keywords %>% str_sub(2, -2) %>% str_split(",")

for (i in 1:length(keywords)){
  keywords[[i]] = str_trim(keywords[[i]])
}
keywords


# outputting abstracts as .txt files
dir.create("BA_abstracts")

for (i in 1:length(abstracts)){
  fname = sprintf("BA_abstracts/%03d.txt", i)
  con = file(fname)
  writeLines(abstracts[i], con)
}
