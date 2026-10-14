/// One year of school. Each year has its own ordered lesson.
enum ClassYear { std1, std2, std3, std4, std5 }

enum StepKind { teach, ask }

/// A single teach card or a single question. The child sees one at a time.
class LessonStep {
  const LessonStep.teach({
    required this.heading,
    required this.picture,
    required this.word,
    required this.note,
    this.parts = const [],
  }) : kind = StepKind.teach,
       prompt = '',
       choices = const [],
       answer = '',
       explain = '';

  const LessonStep.ask({
    required this.heading,
    required this.prompt,
    required this.picture,
    required this.choices,
    required this.answer,
    required this.explain,
  }) : kind = StepKind.ask,
       word = '',
       note = '',
       parts = const [];

  final StepKind kind;
  final String heading;
  final String picture;
  final String word;
  final String note;
  final List<String> parts;
  final String prompt;
  final List<String> choices;
  final String answer;
  final String explain;
}

class ClassPath {
  const ClassPath({
    required this.year,
    required this.title,
    required this.learns,
    required this.steps,
  });

  final ClassYear year;
  final String title;
  final String learns;
  final List<LessonStep> steps;
}

const List<ClassPath> classPaths = [
  ClassPath(
    year: ClassYear.std1,
    title: 'इयत्ता १',
    learns: 'चित्र पाहून शब्द ओळखणे',
    steps: [
      LessonStep.teach(
        heading: 'नवा शब्द',
        picture: '🍎',
        word: 'सफरचंद',
        note: 'हे फळ आहे. चित्र पहा आणि शब्द वाचा.',
      ),
      LessonStep.ask(
        heading: 'ओळख',
        prompt: 'हे चित्र काय आहे?',
        picture: '🍎',
        choices: ['केळी', 'सफरचंद', 'दूध'],
        answer: 'सफरचंद',
        explain: 'हे सफरचंद आहे. लाल फळ.',
      ),
      LessonStep.teach(
        heading: 'नवा शब्द',
        picture: '🥕',
        word: 'गाजर',
        note: 'ही भाजी आहे. गाजर नारंगी असते.',
      ),
      LessonStep.ask(
        heading: 'ओळख',
        prompt: 'हे चित्र काय आहे?',
        picture: '🥕',
        choices: ['गाजर', 'आंबा', 'केळी'],
        answer: 'गाजर',
        explain: 'हे गाजर आहे. ही भाजी आहे.',
      ),
      LessonStep.teach(
        heading: 'नवा शब्द',
        picture: '🍌',
        word: 'केळी',
        note: 'हे फळ आहे. केळी पिवळी असते.',
      ),
      LessonStep.ask(
        heading: 'ओळख',
        prompt: 'हे चित्र काय आहे?',
        picture: '🍌',
        choices: ['दूध', 'सफरचंद', 'केळी'],
        answer: 'केळी',
        explain: 'ही केळी आहे. पिवळे फळ.',
      ),
      LessonStep.ask(
        heading: 'पुन्हा एकदा',
        prompt: 'केळी कोणते चित्र आहे?',
        picture: '🍌',
        choices: ['🍎 सफरचंद', '🍌 केळी', '🥕 गाजर'],
        answer: '🍌 केळी',
        explain: 'केळी पिवळी असते. 🍌 हे केळीचे चित्र आहे.',
      ),
    ],
  ),
  ClassPath(
    year: ClassYear.std2,
    title: 'इयत्ता २',
    learns: 'शब्द वाचून चित्र ओळखणे',
    steps: [
      LessonStep.teach(
        heading: 'शब्द वाचा',
        picture: '🍌',
        word: 'केळी',
        parts: ['के', 'ळी'],
        note: 'आधी शब्द वाचा. मग चित्र आठवा.',
      ),
      LessonStep.ask(
        heading: 'चित्र शोधा',
        prompt: 'केळी कोणते चित्र आहे?',
        picture: '🍌',
        choices: ['🍎', '🥕', '🍌'],
        answer: '🍌',
        explain: 'केळी हे पिवळे फळ आहे. चित्र 🍌.',
      ),
      LessonStep.teach(
        heading: 'शब्द वाचा',
        picture: '🥕',
        word: 'गाजर',
        parts: ['गा', 'जर'],
        note: 'गा + जर मिळून गाजर.',
      ),
      LessonStep.ask(
        heading: 'चित्र शोधा',
        prompt: 'गाजर कोणते चित्र आहे?',
        picture: '🥕',
        choices: ['🥕', '🍎', '🥛'],
        answer: '🥕',
        explain: 'गाजर ही भाजी आहे. चित्र 🥕.',
      ),
      LessonStep.teach(
        heading: 'अक्षर जोडा',
        picture: '🍅',
        word: 'टोमॅटो',
        parts: ['टो', 'मॅ', 'टो'],
        note: 'टो + मॅ + टो मिळून टोमॅटो.',
      ),
      LessonStep.ask(
        heading: 'शब्द तपासा',
        prompt: 'टो + मॅ + टो कोणता शब्द होतो?',
        picture: '🍅',
        choices: ['टोमॅटो', 'गाजर', 'केळी'],
        answer: 'टोमॅटो',
        explain: 'टो, मॅ आणि टो मिळून टोमॅटो होतो.',
      ),
    ],
  ),
  ClassPath(
    year: ClassYear.std3,
    title: 'इयत्ता ३',
    learns: 'छोटे वाक्य वाचणे',
    steps: [
      LessonStep.teach(
        heading: 'वाक्य वाचा',
        picture: '🍎',
        word: 'मला सफरचंद घ्यायचे आहे.',
        parts: ['मला', 'सफरचंद', 'घ्यायचे आहे'],
        note: 'मला म्हणजे मला हवे. घ्यायचे आहे म्हणजे घेणे.',
      ),
      LessonStep.ask(
        heading: 'वाक्य समजून घ्या',
        prompt: 'या वाक्यात काय घ्यायचे आहे?',
        picture: '🍎',
        choices: ['सफरचंद', 'गाजर', 'दूध'],
        answer: 'सफरचंद',
        explain: 'वाक्यात सफरचंद आहे. तेच घ्यायचे आहे.',
      ),
      LessonStep.teach(
        heading: 'दुकान वाचा',
        picture: '🥛',
        word: 'दूध डेअरी',
        note: 'या दुकानात दूध मिळते.',
      ),
      LessonStep.ask(
        heading: 'योग्य दुकान',
        prompt: 'मला दूध घ्यायचे आहे. कोणते दुकान?',
        picture: '🥛',
        choices: ['भाजी मंडई', 'दूध डेअरी', 'पुस्तकांचे दुकान'],
        answer: 'दूध डेअरी',
        explain: 'दूध दूध डेअरीत मिळते.',
      ),
      LessonStep.teach(
        heading: 'वाक्य वाचा',
        picture: '🥕',
        word: 'मला गाजर घ्यायचे आहे.',
        note: 'गाजर ही भाजी आहे. भाजी भाजी मंडईत मिळते.',
      ),
      LessonStep.ask(
        heading: 'योग्य दुकान',
        prompt: 'गाजर कोणत्या दुकानात मिळेल?',
        picture: '🥕',
        choices: ['भाजी मंडई', 'कपड्यांचे दुकान', 'दूध डेअरी'],
        answer: 'भाजी मंडई',
        explain: 'गाजर ही भाजी आहे. ती भाजी मंडईत मिळते.',
      ),
    ],
  ),
  ClassPath(
    year: ClassYear.std4,
    title: 'इयत्ता ४',
    learns: 'किंमत वाचून हिशोब करणे',
    steps: [
      LessonStep.teach(
        heading: 'किंमत वाचा',
        picture: '🥭',
        word: 'आंबा — ₹30',
        parts: ['सफरचंद ₹20', 'केळी ₹15', 'आंबा ₹30'],
        note: 'किंमत म्हणजे ती वस्तू घेताना किती रुपये द्यायचे.',
      ),
      LessonStep.ask(
        heading: 'किंमत ओळखा',
        prompt: 'आंब्याची किंमत किती आहे?',
        picture: '🥭',
        choices: ['₹15', '₹20', '₹30'],
        answer: '₹30',
        explain: 'आंबा ₹30 आहे. केळी ₹15 आणि सफरचंद ₹20.',
      ),
      LessonStep.teach(
        heading: 'हिशोब पाहा',
        picture: '🍎',
        word: '₹50 − ₹35 = ₹15',
        parts: ['सफरचंद ₹20', 'केळी ₹15', 'मिळून ₹35'],
        note: 'तुझ्याकडे ₹50 आहेत. 20 अधिक 15 म्हणजे 35. 50 मधून 35 वजा केले की 15 उरतात.',
      ),
      LessonStep.ask(
        heading: 'उरलेले पैसे',
        prompt: 'सफरचंद आणि केळी घेतल्यावर किती रुपये उरतील?',
        picture: '💰',
        choices: ['₹15', '₹35', '₹50'],
        answer: '₹15',
        explain: '20 + 15 = 35. 50 − 35 = 15. पंधरा रुपये उरतात.',
      ),
    ],
  ),
  ClassPath(
    year: ClassYear.std5,
    title: 'इयत्ता ५',
    learns: 'वाक्य जुळवून सांगणे',
    steps: [
      LessonStep.teach(
        heading: 'वाक्याचा क्रम',
        picture: '🍎',
        word: 'मला दोन सफरचंद हवे आहेत.',
        parts: ['मला', 'दोन', 'सफरचंद', 'हवे आहेत'],
        note: 'आधी मला, मग किती, मग वस्तू, शेवटी हवे आहेत.',
      ),
      LessonStep.ask(
        heading: 'योग्य वाक्य',
        prompt: 'योग्य वाक्य कोणते?',
        picture: '🍎',
        choices: [
          'मला दोन सफरचंद हवे आहेत.',
          'दोन मला आहेत सफरचंद हवे.',
          'हवे आहेत मला सफरचंद.',
        ],
        answer: 'मला दोन सफरचंद हवे आहेत.',
        explain: 'क्रम: मला, दोन, सफरचंद, हवे आहेत.',
      ),
      LessonStep.teach(
        heading: 'आणखी एक वाक्य',
        picture: '🥭',
        word: 'मला दोन आंबे हवे आहेत.',
        parts: ['मला', 'दोन', 'आंबे', 'हवे आहेत'],
        note: 'आंबे म्हणजे अनेक आंबे. क्रम तोच ठेवा.',
      ),
      LessonStep.ask(
        heading: 'योग्य क्रम',
        prompt: 'शब्द योग्य क्रमाने कोणते वाक्य बनवतात?',
        picture: '🥭',
        choices: [
          'मला दोन आंबे हवे आहेत.',
          'आंबे दोन मला हवे आहेत.',
          'हवे आहेत आंबे मला दोन.',
        ],
        answer: 'मला दोन आंबे हवे आहेत.',
        explain: 'मला दोन आंबे हवे आहेत. हाच क्रम बरोबर आहे.',
      ),
      LessonStep.ask(
        heading: 'वाक्य वाचून दुकान',
        prompt: 'मला पुस्तक घ्यायचे आहे. कोणते दुकान?',
        picture: '📚',
        choices: ['पुस्तकांचे दुकान', 'भाजी मंडई', 'दूध डेअरी'],
        answer: 'पुस्तकांचे दुकान',
        explain: 'पुस्तक पुस्तकांच्या दुकानात मिळते.',
      ),
    ],
  ),
];

ClassPath pathFor(ClassYear year) {
  for (final path in classPaths) {
    if (path.year == year) {
      return path;
    }
  }
  return classPaths.first;
}
