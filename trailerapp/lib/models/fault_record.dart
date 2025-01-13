class FaultRecord {
  final String date;
  final String faultDescription;
  final String faultCode;
  final String solution;
  final List<String> changedParts;
  final String mechanicName;
  final double cost;
  // notes eliminadas

  FaultRecord({
    required this.date,
    required this.faultDescription,
    required this.faultCode,
    required this.solution,
    this.changedParts = const [],
    required this.mechanicName,
    required this.cost,
    // notes eliminadas
  });
}
