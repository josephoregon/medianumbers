import re
import nltk
from newspaper import Article
import streamlit as st

st.set_page_config(
    page_title='medianumbers',
    page_icon='🗞'
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
        via_source = '@NewsmaxLive'
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
        via_source = '@NationalFile'
    elif 'pjmedia' in source_url:
        via_source = '@PJMedia'
    elif 'foxnews' in source_url:
        via_source = 'Fox News'
    elif 'thefederalist' in source_url:
        via_source = 'The Federalist'
    elif 'therightscoop' in source_url:
        via_source = '@TheRightScoop'
    elif 'thepoliticalinsider' in source_url:
        via_source = 'The Political Insider'
    elif 'protrumpnews' in source_url:
        via_source = '@ProTrumpNews'
    elif 'waynedupree' in source_url:
        via_source = '@WayneDupreeShow'
    elif 'thepalmierireport' in source_url:
        via_source = '@Thepalmierireport'
    elif 'conservativebrief' in source_url:
        via_source = '@ConservativeBrief'
    elif 'trendingpolitics' in source_url:
        via_source = 'Trending Politics'
    elif 'westernjournal' in source_url:
        via_source = 'The Western Journal'
    elif '100percentfedup' in source_url:
        via_source = '@100percentfedup'
    else:
        via_source = ''

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
via {}

{}

• {}

• {}

• {}

• {}

• {}

{}

        '''.format(via_source, article_title, bullet_1, bullet_2,
                   bullet_3, bullet_4, bullet_5, source_url)

    with st.spinner("Formatting code ..."):
        st.code(default_text, language='html')
