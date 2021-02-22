import re
import nltk
from newspaper import Article
import streamlit as st

title = st.title("medianumbers")
st.markdown("[_by JosephOregon, Data Scientist_](https://www.linkedin.com/in/josephrosas/)")
st.markdown("---")

default_text = st.text_input("Enter URL")

if not default_text:

    default_text = 'You will see a summary of the article entered.'

else:
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

    default_text = '''
    
{}

• {}

• {}

• {}

• {}

• {}

{}
    
    '''.format(article_title, bullet_1, bullet_2, bullet_3, bullet_4, bullet_5, source_url)

    default_text = re.sub('[*{}]', '', default_text)
    default_text = default_text.replace('according to the report.', '')
    default_text = default_text.replace('”', '"')
    default_text = default_text.replace(',"', '"')

with st.spinner("Formatting code ..."):
    st.code(default_text, language='html')
