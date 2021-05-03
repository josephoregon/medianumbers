"""
@Author: Joseph Rosas
Create Date: Feb. 21st 2021
"""
import streamlit as st
import heapq
import nltk
import re
from newspaper import Article

st.set_page_config(
    page_title='News Analytics',
    page_icon='📰'
)

st.title("MEDIA NUMBERS")

st.markdown("[_by Joseph Rosas, Data Scientist_]" "(https://www.linkedin.com/in/josephrosas/)")

st.markdown("---")

nltk.download('punkt')
nltk.download('stopwords')

sentence_length = st.selectbox('Summary Sentence Count:', [1, 2, 3, 4, 5, 6])

url = st.text_input("Paste Article URL Below")

if url != '':
    article = Article(url)
    article.download()
    article.parse()
    article.nlp()

    article_title = article.title
    source_url = article.url
    article_text = article.text
    article_text_formatted = re.sub(r'\s+', ' ', article_text)
    sentence_list = nltk.sent_tokenize(article_text_formatted)
    stopwords = nltk.corpus.stopwords.words('english')

    word_frequencies = {}

    for word in nltk.word_tokenize(article_text_formatted):
        if len(word) >= 5:
            if word not in stopwords:
                if word not in word_frequencies.keys():
                    word_frequencies[word] = 1
                else:
                    word_frequencies[word] += 1

    sorted_values = sorted(word_frequencies.values(),
                           reverse=True)  # Sort the values
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

    summary_sentences = heapq.nlargest(sentence_length, sentence_scores, key=sentence_scores.get)
    summary = ' '.join(summary_sentences)

    tag_list = []

    for w in sorted_list:
        w = w.capitalize()
        tag = ' #' + w
        tag_list.append('{}'.format(tag))
    tags = ''.join(tag_list)

    if 'BREAKING' in article_title:
        default_text = '''
𝘽𝙍𝙀𝘼𝙆𝙄𝙉𝙂 𝙃𝙀𝘼𝘿𝙇𝙄𝙉𝙀 🚨
{}

𝙎𝙐𝙈𝙈𝘼𝙍𝙔  ❝❞
{}

𝙎𝙊𝙐𝙍𝘾𝙀  ↴
{}
                                        '''.format(article_title, summary, source_url)
    else:
        default_text = '''
𝙃𝙀𝘼𝘿𝙇𝙄𝙉𝙀  🎙
{}

𝙎𝙐𝙈𝙈𝘼𝙍𝙔  ❝❞
{}

𝙎𝙊𝙐𝙍𝘾𝙀  ↴
{}
                                '''.format(article_title, summary, source_url)

    with st.spinner("Formatting code ..."):
        st.code(default_text, language='html')
