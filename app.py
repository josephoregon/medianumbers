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


sentence_length = st.multiselect('Summary Sentence Count:', [1, 2, 3, 4, 5, 6])

