import re
import nltk
from newspaper import Article
import streamlit as st

st.set_page_config(
    page_title='medianumbers',
    page_icon='🗞'
)

title = st.title("medianumbers")
st.markdown("[_by JosephOregon, Data Scientist_]"
            "(https://www.linkedin.com/in/josephrosas/)")
st.markdown("---")
st.markdown("Get only the important stuff from "
            "news articles and format them into bullet points!")
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

    if 'newsmax' in source_url:
        via_source = 'Newsmax'
    elif 'oann' in source_url:
        via_source = 'OAN'
    elif 'redstate' in source_url:
        via_source = 'RedState'
    elif 'thegatewaypundit' in source_url:
        via_source = '@GatewayPundit'
    elif 'theepochtimes' in source_url:
        via_source = '@TheEpochTimes'
    elif 'newsbusters' in source_url:
        via_source = 'NewsBusters'
    elif 'nationalreview' in source_url:
        via_source = 'National Review Online'
    elif 'nationalfile' in source_url:
        via_source = 'NationalFile'
    elif 'pjmedia' in source_url:
        via_source = '@PJMedia'
    elif 'foxnews' in source_url:
        via_source = 'Fox News'
    elif 'thefederalist' in source_url:
        via_source = 'The Federalist'
    elif 'therightscoop' in source_url:
        via_source = 'The Right Scoop'
    elif 'thepoliticalinsider' in source_url:
        via_source = 'The Political Insider'
    elif 'waynedupree' in source_url:
        via_source = '@WayneDupreeShow'
    else:
        via_source = 'JosephOregon'

    default_text = '''

via {}
    
{}

• {}

• {}

• {}

• {}

• {}

{}
    
    '''.format(via_source, article_title, bullet_1, bullet_2, bullet_3, bullet_4, bullet_5, source_url)

    default_text = re.sub('[*{}]', '', default_text)
    default_text = default_text.replace('according to the report.', '')
    default_text = default_text.replace('”', '"')
    default_text = default_text.replace(',"', '"')

with st.spinner("Formatting code ..."):
    st.code(default_text, language='html')
