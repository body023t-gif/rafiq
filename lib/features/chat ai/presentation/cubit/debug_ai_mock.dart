import 'package:flutter/foundation.dart';
import 'package:rafiq/features/chat%20ai/models/chat_model.dart';

class DebugAiMock {
  static AskQuestionResponseModel? tryAnswer(String userMessage, String sessionId) {
    if (!kDebugMode) return null;

    final normalized = _normalize(userMessage);
    String? answer;

    if (_matches(normalized, [
      'كام ساعة لازم اتخرج',
      'عدد الساعات المطلوبة للتخرج',
      'محتاج كام ساعة علشان اتخرج',
      'ساعات التخرج',
    ])) {
      answer = '''بناءً على اللائحة الداخلية لبرنامج بكالوريوس الحاسبات والمعلومات – تخصص الذكاء الاصطناعي – جامعة المنصورة:

عدد الساعات المطلوبة للتخرج هو 138 ساعة معتمدة.

وتتوزع كالتالي:

• متطلبات الجامعة: 5 ساعات
• متطلبات الكلية الإجبارية: 73 ساعة
• متطلبات الكلية الاختيارية: 9 ساعات
• متطلبات التخصص الإجبارية: 42 ساعة
• متطلبات التخصص الاختيارية: 9 ساعات

الإجمالي: 138 ساعة معتمدة.

ولا يكفي إنهاء 138 ساعة فقط، بل يجب أيضًا:

• النجاح في جميع المقررات المطلوبة.
• استيفاء جميع المتطلبات السابقة (Prerequisites).
• إنهاء مشروع التخرج.
• إنهاء التدريب العملي إذا كان مطلوبًا.
• تحقيق الحد الأدنى للمعدل التراكمي.''';
    } else if (_matches(normalized, [
      'اقل gpa للتخرج',
      'اقل معدل للتخرج',
      'الحد الادنى لل gpa',
      'كام gpa علشان اتخرج',
    ])) {
      answer = '''طبقًا للائحة:

الحد الأدنى للمعدل التراكمي (CGPA) للتخرج هو:

2.00 من 4.00

ولا يمنح الطالب الدرجة العلمية إلا إذا:

• أنهى جميع الساعات المطلوبة.
• نجح في جميع المقررات المطلوبة.
• حقق معدلًا تراكميًا لا يقل عن 2.00.''';
    } else if (_matches(normalized, [
      'لو جبت 75',
      '75 gpa',
      '75 في مادة',
    ])) {
      answer = '''طبقًا لجدول التقديرات:

75% تقع ضمن المدى 73–76%.

وبالتالي:

• التقدير: C+
• Grade Point: 2.30

وهذا يمثل نقاط المادة فقط وليس المعدل التراكمي.

مثال:

إذا كانت المادة 3 ساعات:

2.30 × 3 = 6.9 نقاط جودة.

ويحسب الـ CGPA بجمع نقاط الجودة لجميع المواد ثم قسمتها على إجمالي الساعات المعتمدة.''';
    }

    if (answer != null) {
      return AskQuestionResponseModel(
        answer: answer,
        sessionId: sessionId.isNotEmpty ? sessionId : 'mock-session-id',
        messageId: 'mock-msg-\${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    return null;
  }

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\d\u0600-\u06FF]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('؟', '')
        .replaceAll('%', '')
        .trim();
  }

  static bool _matches(String normalizedMessage, List<String> patterns) {
    for (final pattern in patterns) {
      final normalizedPattern = _normalize(pattern);
      if (normalizedMessage.contains(normalizedPattern)) {
        return true;
      }
    }
    return false;
  }
}
