class Question {
  var _question;
  var _correctAnswer;
  var _explanation;

  Question(String question, bool correctAnswer, String explanation) {
    _question = question;
    _correctAnswer = correctAnswer;
    _explanation = explanation;
  }

  get correctAnswer => _correctAnswer;
  get question => _question;
  get explanation => _explanation;
}