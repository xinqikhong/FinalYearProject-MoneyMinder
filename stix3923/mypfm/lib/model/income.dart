class Income {
  int incomeId;
  DateTime incomeDate;
  double incomeAmount;
  String incomeCategory;
  String? incomeNote;
  String? incomeDesc;
  int userId;
  int accountId;
  DateTime incomeCreationDate;

  Income({
    required this.incomeId,
    required this.incomeDate,
    required this.incomeAmount,
    required this.incomeCategory,
    this.incomeNote,
    this.incomeDesc,
    required this.userId,
    required this.accountId,
    required this.incomeCreationDate,
  });

  Income.fromJson(Map<String, dynamic> json)
      : incomeId = json['income_id'],
        incomeDate = DateTime.parse(json['income_date']),
        incomeAmount = json['income_amount'],
        incomeCategory = json['income_category'],
        incomeNote = json['income_note'],
        incomeDesc = json['income_desc'],
        userId = json['user_id'],
        accountId = json['account_id'],
        incomeCreationDate = DateTime.parse(json['income_creationdate']);

  Map<String, dynamic> toJson() => {
        'income_id': incomeId,
        'income_date': incomeDate.toString(),
        'income_amount': incomeAmount,
        'income_category': incomeCategory,
        'income_note': incomeNote,
        'income_desc': incomeDesc,
        'user_id': userId,
        'account_id': accountId,
        'income_creationdate': incomeCreationDate.toString(),
      };
}