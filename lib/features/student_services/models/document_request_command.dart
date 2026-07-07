class DocumentRequestCommand {
  final String studentId;
  final String documentType;
  final String remarks;
  final String topic;
  final String attachmentUrl;

  const DocumentRequestCommand({
    required this.studentId,
    required this.documentType,
    required this.remarks,
    required this.topic,
    this.attachmentUrl = "",
  });

  Map<String, dynamic> toJson() {
    return {
      "studentId": studentId,
      "documentType": documentType,
      "remarks": remarks,
      "topic": topic,
      "attachmentUrl": attachmentUrl,
    };
  }
}
