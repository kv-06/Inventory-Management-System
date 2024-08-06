class HistoryRecord {
  final int itemId;
  final String dateTime;
  final int updating;
  final int qty;

  HistoryRecord({
    required this.itemId,
    required this.dateTime,
    required this.updating,
    required this.qty,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'dateTime': dateTime,
      'updating': updating,
      'qty': qty,
    };
  }
  @override
  String toString() {
    return 'HistoryRecord(itemId: $itemId, dateTime: $dateTime, updating: $updating, qty: $qty)';
  }


}

