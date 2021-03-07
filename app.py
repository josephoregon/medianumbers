import re
import nltk
from newspaper import Article
import streamlit as st
import heapq

st.set_page_config(
    page_title='medianumbers',
    page_icon='🗞'
)

st.markdown(
    """
<style>
.reportview-container .markdown-text-container {
    font-family: monospace;
}
.sidebar .sidebar-content {
    background-image: linear-gradient(#2e7bcf,#2e7bcf);
    color: white;
}
.Widget>label {
    color: white;
    font-family: monospace;
}
[class^="st-b"]  {
    color: white;
    font-family: monospace;
}
.st-bb {
    background-color: transparent;
}
.st-at {
    background-color: #0c0080;
}
footer {
    font-family: monospace;
}
.reportview-container .main footer, .reportview-container .main footer a {
    color: #0c0080;
}
header .decoration {
    background-image: none;
}

</style>
""",
    unsafe_allow_html=True,
)



nltk.download('stopwords')

title = st.title("Media-Numbers")
st.markdown("[_by JosephOregon, Data Scientist_]"
            "(https://www.linkedin.com/in/josephrosas/)")
st.markdown("---")
st.markdown("Do you want to summarize an article? Get only the "
            "important stuff from news articles and format them"
            " into bullet points! I will continue to make changes,"
            "as far as enhancements and repairs.")
st.markdown("---")

default_text = st.text_input("Enter Article's URL")

st.text('OR')

paste_text = st.text_area('Copy & Paste Article Text')

if default_text:

    article = Article(default_text)
    nltk.download('punkt')
    article.download()
    article.parse()
    article.nlp()

    article_title = article.title

    bullet_1 = str(article.summary.split('\n')[0])
    bullet_2 = str(article.summary.split('\n')[1])
    bullet_3 = str(article.summary.split('\n')[2])
    bullet_4 = str(article.summary.split('\n')[3])
    bullet_5 = str(article.summary.split('\n')[4])

    source_url = article.url

    # Removing Square Brackets and Extra Spaces
    article_text = re.sub(r'\[[0-9]*\]', ' ', default_text)
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

    default_text = '''
{}

↓
↓

{}

        '''.format(article_title, source_url)

    with st.spinner("Formatting code ..."):
        st.code(default_text, language='html')

if paste_text:

    # Removing Square Brackets and Extra Spaces
    article_text = re.sub(r'\[[0-9]*\]', ' ', paste_text)
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

    maximum_frequncy = max(word_frequencies.values())

    for word in word_frequencies.keys():
        word_frequencies[word] = (word_frequencies[word] / maximum_frequncy)

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

    default_text = '''{}'''.format(summary)

    with st.spinner("Formatting code ..."):
        st.write(summary)
