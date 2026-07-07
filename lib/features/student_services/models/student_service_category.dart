enum StudentServiceCategory {
  appointment("حجز موعد"),
  document("طلب وثيقة"),
  inquiry("استفسار عام");

  final String arabicTitle;
  const StudentServiceCategory(this.arabicTitle);

  static StudentServiceCategory fromTitle(String title) {
    if (title.contains("إثبات قيد") || title.contains("بيان درجات") || title == "طلب وثيقة") {
      return StudentServiceCategory.document;
    }
    if (title.contains("إرشاد") || title == "حجز موعد") {
      return StudentServiceCategory.appointment;
    }
    if (title.contains("شكوى") || title.contains("دعم") || title == "استفسار عام") {
      return StudentServiceCategory.inquiry;
    }
    return StudentServiceCategory.appointment;
  }
}
