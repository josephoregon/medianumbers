import heapq
import re
import nltk
from newspaper import Article
import streamlit as st

st.set_page_config(
    page_title='medianumbers',
    page_icon='🗞'
)

st.markdown("""
<style>
body {
  background: #ff0099; 
  background: -webkit-linear-gradient(to right, #ff0099, #493240); 
  background: linear-gradient(to right, #ff0099, #493240); 
}
</style>
    """, unsafe_allow_html=True)

nltk.download('stopwords')

title = st.title("Media-Numbers")

st.markdown("[_by JosephOregon, Data Scientist_]"
            "(https://www.linkedin.com/in/josephrosas/)")

st.markdown("---")

default_text = st.text_input("Paste News Article URL")

if default_text:

    article = Article(default_text)

    nltk.download('punkt')

    article.download()
    article.parse()
    article.nlp()

    article_title = article.title

    source_url = article.url

    article_summary = article.summary

    # Removing Square Brackets and Extra Spaces
    article_text = re.sub(r'\[[0-9]*\]', ' ', article_summary)
    article_text = re.sub(r'\s+', ' ', article_text)

    # Removing special characters and digits
    formatted_article_text = re.sub('[^a-zA-Z]', ' ', article_text)
    formatted_article_text = re.sub(r'\s+', ' ', formatted_article_text)

    sentence_list = nltk.sent_tokenize(article_text)
    stopwords = nltk.corpus.stopwords.words('english')

    word_frequencies = {}
    for word in nltk.word_tokenize(formatted_article_text):
        if len(word) > 4:
            if word not in stopwords:
                if word not in word_frequencies.keys():
                    word_frequencies[word] = 1
                else:
                    word_frequencies[word] += 1

    sorted_values = sorted(word_frequencies.values(), reverse=True)  # Sort the values
    sorted_dict = {}

    for i in sorted_values:
        for k in word_frequencies.keys():
            if word_frequencies[k] == i:
                sorted_dict[k] = word_frequencies[k]
                break

    sorted_list = list(sorted_dict.keys())

    maximum_freq = max(word_frequencies.values())

    for word in word_frequencies.keys():
        word_frequencies[word] = (word_frequencies[word] / maximum_freq)

    sentence_scores = {}
    for sent in sentence_list:
        for word in nltk.word_tokenize(sent.lower()):
            if word in word_frequencies.keys():
                if len(sent.split(' ')) < 30:
                    if sent not in sentence_scores.keys():
                        sentence_scores[sent] = word_frequencies[word]
                    else:
                        sentence_scores[sent] += word_frequencies[word]

    summary_sentences = heapq.nlargest(7, sentence_scores, key=sentence_scores.get)

    summary = ' '.join(summary_sentences)

    if 'BREAKING' in article_title:
        default_text = '''
🚨 {}

🔑 SUMMARY: {}

🔗 {}
            '''.format(article_title, summary, source_url)
    else:
        default_text = '''
📰 {}

🔑 SUMMARY: {}

🔗 {}
            '''.format(article_title, summary, source_url)

    with st.spinner("Formatting code ..."):
        st.code(default_text, language='html')
