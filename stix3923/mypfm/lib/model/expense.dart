class Expense {
  String? expenseId;
  String? expenseDate;
  String? expenseAmount;
  String? expenseCategory;
  String? expenseNote;
  String? expenseDesc;
  String? expenseAccount;
  String? expenseCreationDate;
  String? userId;

  Expense({
    this.expenseId,
    this.expenseDate,
    this.expenseAmount,
    this.expenseCategory,
    this.expenseNote,
    this.expenseDesc,
    this.expenseAccount,
    this.expenseCreationDate,
    this.userId,
  });

  Expense.fromJson(Map<String, dynamic> json)
      : expenseId = json['expense_id'],
        expenseDate = json['expense_date'],
        expenseAmount = json['expense_amount'],
        expenseCategory = json['expense_category'],
        expenseNote = json['expense_note'],
        expenseDesc = json['expense_desc'],
        expenseAccount = json['expense_account'],
        expenseCreationDate = json['expense_creationdate'],
        userId = json['user_id'];

 Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['expense_id'] = expenseId;
    data['expense_date'] = expenseDate;
    data['expense_amount'] = expenseAmount;
    data['expense_category'] = expenseCategory;
    data['expense_note'] = expenseNote;
    data['expense_desc'] = expenseDesc;
    data['expense_account'] = expenseAccount;
    data['expense_creationdate'] = expenseCreationDate;
    data['user_id'] = userId;
    return data;
  }

/*
  Map<String, dynamic> toJson() => {
        'expense_id': expenseId,
        'expense_date': expenseDate.toString(),
        'expense_amount': expenseAmount,
        'expense_category': expenseCategory,
        'expense_note': expenseNote,
        'expense_desc': expenseDesc,
        'expense_account': expenseAccount,
        'expense_creationdate': expenseCreationDate.toString(),
        'user_id': userId,
      };
      */
}