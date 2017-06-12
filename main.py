import codecs
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

import nltk
import requests


CLEAN_FILE_NAME = 'clean.txt'

RESOURCES_PATH = os.path.join(os.path.dirname(__file__), 'resources')
XML_TO_TEXT = os.path.join(RESOURCES_PATH, 'xml-to-text.jar')
SENTIMENT_ANALYSIS = os.path.join(RESOURCES_PATH, 'sentiment-analysis.jar')
MEDICAL_TERMS = os.path.join(RESOURCES_PATH, 'termeni-medicali.txt')


def extract_clean_text(input_file_name, dir_name):
    """Extracts the clean text from an xml file.

    Writes the clean text to a file called clean.txt in a temporary directory.
    """
    subprocess.Popen(
        ['java', '-jar', XML_TO_TEXT,
         input_file_name, os.path.join(dir_name, CLEAN_FILE_NAME)]
    ).wait()


def get_sentiment(file_name):
    """Performs sentiment analysis on an xml file."""
    stdout, _ = subprocess.Popen(
        ['java', '-jar', SENTIMENT_ANALYSIS, file_name], stdout=subprocess.PIPE
    ).communicate()
    return float(stdout.strip())


def get_average_words_per_sentence(file_name):
    """Counts the number of sentences and of words and returns the
    average number of words per sentence.
    """
    with codecs.open(file_name, 'r', encoding='utf-8') as fin:
        text = fin.read()
    sentences = len(nltk.sent_tokenize(text))
    words = len(nltk.word_tokenize(text))
    try:
        return float(words)/sentences
    except ZeroDivisionError:
        return 0


def get_medical_terms_frequency(file_name):
    """Counts how many medical terms are used and returns their
    number over the total number of words in the article.
    """
    with codecs.open(file_name, 'r', encoding='utf-8') as fin:
        text = fin.read()
    words = [w.strip().lower() for w in nltk.word_tokenize(text)]

    with codecs.open(MEDICAL_TERMS, 'r', encoding='utf-8') as fin:
        medical_terms = fin.readlines()
    medical_terms = set([w.strip().lower() for w in medical_terms])

    medical_terms_used = 0
    for w in words:
        if w in medical_terms:
            medical_terms_used += 1

    try:
        return float(medical_terms_used)/len(words)
    except ZeroDivisionError:
        return 0


def get_author_views_and_publications(file_name):
    with codecs.open(file_name, 'r', encoding='utf-8') as fin:
        text = fin.read()
    author_id = re.search('http://loop.frontiersin.org/people/(\d+)', text)
    if not author_id:
        return 0, 0
    text = requests.get('https://impact-api.frontiersin.org/v2/Authors({0})/ProfileOverview'.format(author_id.group(1))).text
    info = json.loads(text)
    total_views = info['totalViews']
    text = requests.get('http://loop.frontiersin.org/api/v1/users/{0}/publications/totals'.format(author_id.group(1))).text
    info = json.loads(text)
    total_publications = info['Confirmed']
    return total_views, total_publications


def main():
    """Sample usage:

    python main.py path_to_article.xml
    """
    input_file_name = sys.argv[1]
    dir_name = tempfile.mkdtemp()
    try:
        extract_clean_text(input_file_name, dir_name)
        sentiment = get_sentiment(input_file_name)
        print sentiment
        average_words_per_sentence = get_average_words_per_sentence(
            os.path.join(dir_name, CLEAN_FILE_NAME)
        )
        print average_words_per_sentence
        medical_terms_frequency = get_medical_terms_frequency(
            os.path.join(dir_name, CLEAN_FILE_NAME)
        )
        print medical_terms_frequency
        total_views, total_publications = get_author_views_and_publications(input_file_name)
        print total_views
        print total_publications
    finally:
        shutil.rmtree(dir_name)


if __name__ == '__main__':
    main()
