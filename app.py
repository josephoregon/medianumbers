import streamlit as st
import nltk
from newspaper import Article

st.set_page_config(page_title="Media Numbers Co.",
                   page_icon="🗽",
                   layout="centered",
                   initial_sidebar_state="expanded")

nltk.download('punkt')

def main():
    st.title("medianumbers")
    st.markdown("keeping the media honest and fair")
    st.markdown("_Creator: JosephOregon, Data Scientist_")
    st.markdown("---")
    
    default_text = st.text_input("Enter URL")

    if not default_text:
        st.write('')
        return

    article = Article(default_text)
    article.download()
    article.parse()
    article.nlp()

    st.write(article.title)  # + ' ' + str(article.publish_date.strftime('(%m-%d-%Y)'))

    st.write('')

    for n in range(0, 5):
        bullet = "• " + str(article.summary.split('\n')[n])
        st.write(bullet)
        st.write('')

    st.write('#{} #{} #{} #{} #{} #{}'.format(
        str(article.keywords[0]),
        str(article.keywords[1]),
        str(article.keywords[2]),
        str(article.keywords[3]),
        str(article.keywords[4]),
        str(article.keywords[5]),
    ))

    st.write('')
    st.write('{}'.format(article.url))


if __name__ == "__main__":
    main()
