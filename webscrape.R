
library(stringr)

# getting from sfu?
# doesn't look like it's gonna work




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


abstractreg = '"Abstract":(.*?),"Access":'
titlereg = '"HTMLTitle":(.*?),"VideoID"'

abstracts = str_match_all(longboi, abstractreg)[[1]][,2]
titles = str_match_all(longboi, titlereg)[[1]][,2]

abstracts[120]
titles

length(abstracts)
length(titles)


# trying to get all papers from given BA journal edition

dir.create("articlehtmls")
volumeroot = "https://projecteuclid.org/journals/bayesian-analysis/"
volumeno = 17
issueno = 1

issueurl = paste0(volumeroot, "volume-", volumeno, "/issue-", issueno)
fname = sprintf("articlehtmls/bayes%02d%01d.txt", volumeno, issueno)

download.file(issueurl, fname)

bayesissue = readLines(fname)
articlereg = '<div class="row TOCLineItemRow1">'

bayesissuechonk = paste(bayesissue, collapse = "\n")

# 1 is full match, 2 has no meaning, 3 is relative link, 4 is article name, 5 has no meaning, 6 has no meaning, 7 is abstract
articledeetsreg = '<div class="TOCLineItemRowCol1">(\\n|.)*?<a href="(.*?\\.full).*?<span class="TOCLineItemText1">(.*?)</span>(\\n|.){1,4000}?<div class="row anchorrel".*?\\W*<p.*?>(.*?)</p>'

articledeetstest = '<div class="TOCLineItemRowCol1">(\\n|.)*?<a href="(.*?\\.full).*?<span class="TOCLineItemText1">(.*?)</span>(\\n|.){1,4000}?<div class="row anchorrel".*?(\\n|.)*?<p.*?>(.*?)</p>'

articledat = str_match_all(bayesissuechonk, articledeetstest)[[1]]

narticles = length(articledat[,1])
articledf = data.frame(volume = rep(volumeno, narticles),
                       issue = rep(issueno, narticles),
                       title = articledat[,4], 
                       link = articledat[,3],
                       abstract = articledat[,7])

articledf$title

allarticledat = articledf

for (volumeno in 15:16){
  for (issueno in 1:4){
    issueurl = paste0(volumeroot, "volume-", volumeno, "/issue-", issueno)
    fname = sprintf("articlehtmls/bayes%02d%01d.txt", volumeno, issueno)
    
    download.file(issueurl, fname)
    
    bayesissue = readLines(fname)
    
    bayesissuechonk = paste(bayesissue, collapse = "\n")
    
    articledat = str_match_all(bayesissuechonk, articledeetstest)[[1]]
    narticles = length(articledat[,1])
    articledf = data.frame(volume = rep(volumeno, narticles),
                           issue = rep(issueno, narticles),
                           title = articledat[,4], 
                           link = articledat[,3],
                           abstract = articledat[,6])
    
    allarticledat = rbind(allarticledat, articledf)
    
  }
}

allarticledat$title
