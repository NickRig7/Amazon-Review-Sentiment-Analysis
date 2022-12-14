am=read.csv(file=file.choose(),sep=",",header = TRUE)
View(am)
str(am)
am$Review=factor(am$Review)
str(am)

library(tm)
am_corpus = VCorpus(VectorSource(am$Text))
print(am_corpus)
inspect(am_corpus[1])
as.character(am_corpus[1])
lapply(am_corpus[1:2], as.character)

am_corpus_clean = tm_map(am_corpus,content_transformer(tolower))
am_corpus_clean = tm_map(am_corpus_clean,removeNumbers)
am_corpus_clean = tm_map(am_corpus_clean,removeWords,stopwords())
am_corpus_clean = tm_map(am_corpus_clean,removePunctuation)

library(SnowballC)
am_corpus_clean = tm_map(am_corpus_clean,stemDocument)
am_corpus_clean = tm_map(am_corpus_clean,stripWhitespace)
am_dtm = DocumentTermMatrix(am_corpus_clean)
am_dtm

am_dtm3=DocumentTermMatrix(am_corpus,control = list(
  tolower = TRUE,
  removeNumbers = TRUE,
  stopwords = function(x){removeWords(x,stopwords())},
  removePunctuation = TRUE,
  stemming = TRUE
))

am_train=am_dtm3[1:200,]
am_test=am_dtm3[200:284,]

am_train_label=am[1:200,]$Review
am_test_label=am[200:284,]$Review

am_dtm_freq_train= removeSparseTerms(am_train,0.999)
am_dtm_freq_train

am_freq_words=findFreqTerms(am_train,5)
str(am_freq_words)

am_dtm_freq_train= am_train[,am_freq_words]
am_dtm_freq_test= am_test[,am_freq_words]

convert_counts=function(x){
  x=ifelse(x>0, "Yes","No")
}

am_train= apply(am_dtm_freq_train, MARGIN = 2, convert_counts)
am_test= apply(am_dtm_freq_test, MARGIN = 2, convert_counts)

library(e1071)
am_model = naiveBayes(am_train, am_train_label)
am_pred = predict(am_model, am_test)
am_pred
table(am_pred, am_test_label)
