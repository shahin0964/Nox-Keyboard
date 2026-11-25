class EnUsDictionary {
  static const List<String> words = [
    'the', 'be', 'to', 'of', 'and', 'a', 'in', 'that', 'have', 'I',
    'it', 'for', 'not', 'on', 'with', 'he', 'as', 'you', 'do', 'at',
    'this', 'but', 'his', 'by', 'from', 'they', 'we', 'say', 'her', 'she',
    'or', 'an', 'will', 'my', 'one', 'all', 'would', 'there', 'their', 'what',
    'so', 'up', 'out', 'if', 'about', 'who', 'get', 'which', 'go', 'me',
    'when', 'make', 'can', 'like', 'time', 'no', 'just', 'him', 'know', 'take',
    'people', 'into', 'year', 'your', 'good', 'some', 'could', 'them', 'see', 'other',
    'than', 'then', 'now', 'look', 'only', 'come', 'its', 'over', 'think', 'also',
    'back', 'after', 'use', 'two', 'how', 'our', 'work', 'first', 'well', 'way',
    'even', 'new', 'want', 'because', 'any', 'these', 'give', 'day', 'most', 'us',
    'hello', 'thanks', 'thank', 'welcome', 'great', 'awesome', 'please', 'sorry', 'love', 'happy',
    'friend', 'family', 'today', 'tomorrow', 'yesterday', 'tonight', 'morning', 'night', 'yes', 'sure',
    'never', 'always', 'maybe', 'really', 'cool', 'nice', 'help', 'call', 'text', 'send',
    'message', 'phone', 'number', 'home', 'office', 'school', 'where', 'why', 'need', 'feel',
    'beautiful', 'wonderful', 'special', 'fine', 'ready', 'okay', 'right', 'here', 'there', 'keep',
    'start', 'stop', 'open', 'close', 'read', 'write', 'talk', 'listen', 'watch', 'play',
    'game', 'movie', 'music', 'song', 'food', 'water', 'coffee', 'tea', 'eat', 'drink',
    'money', 'place', 'world', 'life', 'heart', 'mind', 'body', 'health', 'peace', 'smile'
  ];

  // Bigram next-word prediction pairs: key -> list of probable next words
  static const Map<String, List<String>> bigrams = {
    'i': ['am', 'have', 'will', 'can', 'think', 'know', 'want', 'love', 'need'],
    'how': ['are', 'is', 'was', 'about', 'do', 'can'],
    'how are': ['you', 'things', 'we', 'they'],
    'thank': ['you', 'god', 'goodness'],
    'thank you': ['so', 'very', 'much', 'for'],
    'good': ['morning', 'night', 'afternoon', 'evening', 'job', 'luck', 'idea'],
    'what': ['is', 'are', 'do', 'did', 'about', 'happened', 'time'],
    'where': ['are', 'is', 'did', 'were', 'have', 'do'],
    'see': ['you', 'later', 'soon', 'it', 'that'],
    'see you': ['soon', 'later', 'tomorrow', 'there'],
    'let': ['me', 'us', 'it', 'them'],
    'let me': ['know', 'see', 'check', 'think', 'tell'],
    'i am': ['sorry', 'happy', 'fine', 'ready', 'going', 'here', 'so', 'glad'],
    'have a': ['great', 'good', 'nice', 'wonderful', 'safe'],
    'take': ['care', 'time', 'it', 'your'],
    'take care': ['of', 'and', 'my', 'always'],
    'we': ['are', 'will', 'have', 'can', 'should', 'need'],
    'you': ['are', 'can', 'will', 'have', 'know', 'should'],
    'you are': ['welcome', 'great', 'awesome', 'the', 'so', 'right'],
    'it': ['is', 'was', 'will', 'has', 'would', 'looks'],
    'it is': ['a', 'good', 'great', 'time', 'very', 'not'],
    'do': ['not', 'you', 'it', 'we', 'they'],
    'do you': ['know', 'have', 'want', 'think', 'need', 'like'],
  };
}
