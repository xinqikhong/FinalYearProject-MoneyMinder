class Expense {
  int expenseId;
  DateTime expenseDate;
  double expenseAmount;
  String expenseCategory;
  String? expenseNote;
  String? expenseDesc;
  int accountId;
  DateTime expenseCreationDate;
  int userId;

  Expense({
    required this.expenseId,
    required this.expenseDate,
    required this.expenseAmount,
    required this.expenseCategory,
    this.expenseNote,
    this.expenseDesc,
    required this.accountId,
    required this.expenseCreationDate,
    required this.userId,
  });

  Expense.fromJson(Map<String, dynamic> json)
      : expenseId = json['expense_id'],
        expenseDate = DateTime.parse(json['expense_date']),
        expenseAmount = json['expense_amount'],
        expenseCategory = json['expense_category'],
        expenseNote = json['expense_note'],
        expenseDesc = json['expense_desc'],
        accountId = json['account_id'],
        expenseCreationDate = DateTime.parse(json['expense_creationdate']),
        userId = json['user_id'];

  Map<String, dynamic> toJson() => {
        'expense_id': expenseId,
        'expense_date': expenseDate.toString(),
        'expense_amount': expenseAmount,
        'expense_category': expenseCategory,
        'expense_note': expenseNote,
        'expense_desc': expenseDesc,
        'account_id': accountId,
        'expense_creationdate': expenseCreationDate.toString(),
        'user_id': userId,
      };
}