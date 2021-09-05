class Question {
  var _question;
  var _correctAnswer;
  var _explanation;
  var _asked;

  Question(String question, bool correctAnswer, String explanation) {
    _question = question;
    _correctAnswer = correctAnswer;
    _explanation = explanation;
    _asked = false;
  }

  Question ask() {
    _asked = true;
    return this;
  }

  void reset() {
    _asked = false;
  }

  get correctAnswer => _correctAnswer;
  get question => _question;
  get explanation => _explanation;
  get asked => _asked;
}