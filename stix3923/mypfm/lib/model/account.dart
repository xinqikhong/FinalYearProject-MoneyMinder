class Account {
  int accountId;
  String accountName;
  DateTime accountCreationDate;

  Account({
    required this.accountId,
    required this.accountName,
    required this.accountCreationDate,
  });

  Account.fromJson(Map<String, dynamic> json)
      : accountId = json['account_id'],
        accountName = json['account_name'],
        accountCreationDate = DateTime.parse(json['account_creationdate']);

  Map<String, dynamic> toJson() => {
        'account_id': accountId,
        'account_name': accountName,
        'account_creationdate': accountCreationDate.toString(),
      };
}