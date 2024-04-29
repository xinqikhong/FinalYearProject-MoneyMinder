class Income {
  String? incomeId;
  String? incomeDate;
  String? incomeAmount;
  String? incomeCategory;
  String? incomeNote;
  String? incomeDesc;
  String? userId;
  String? incomeAccount;
  String? incomeCreationDate;

  Income({
    this.incomeId,
    this.incomeDate,
    this.incomeAmount,
    this.incomeCategory,
    this.incomeNote,
    this.incomeDesc,
    this.userId,
    this.incomeAccount,
    this.incomeCreationDate,
  });

  Income.fromJson(Map<String, dynamic> json)
      : incomeId = json['income_id'],
        incomeDate = json['income_date'],
        incomeAmount = json['income_amount'],
        incomeCategory = json['income_category'],
        incomeNote = json['income_note'],
        incomeDesc = json['income_desc'],
        userId = json['user_id'],
        incomeAccount = json['income_account'],
        incomeCreationDate = json['income_creationdate'];

  Map<String, dynamic> toJson() => {
        'income_id': incomeId,
        'income_date': incomeDate.toString(),
        'income_amount': incomeAmount,
        'income_category': incomeCategory,
        'income_note': incomeNote,
        'income_desc': incomeDesc,
        'user_id': userId,
        'income_account': incomeAccount,
        'income_creationdate': incomeCreationDate.toString(),
      };
}
