class Loan {
  final String loanStatus;
  final double requestedAmount; // Expected to be a double
  final int loanTenureMonths;   // Expected to be an int
  final String selectedLoanType;

  Loan({
    required this.loanStatus,
    required this.requestedAmount,
    required this.loanTenureMonths,
    required this.selectedLoanType,
  });

  factory Loan.fromFirestore(Map<String, dynamic> firestoreData) {
    // Debugging: Print types of the fields
    print('requestedAmount type: ${firestoreData['requestedAmount'].runtimeType}');
    print('loanTenureMonths type: ${firestoreData['loanTenureMonths'].runtimeType}');

    return Loan(
      loanStatus: firestoreData['loanStatus'] ?? 'Unknown',
      requestedAmount: (firestoreData['requestedAmount'] ?? 0.0).toDouble(), // Ensuring requestedAmount is a double
      loanTenureMonths: (firestoreData['loanTenureMonths'] ?? 0).toInt(), // Ensure loanTenureMonths is an int
      selectedLoanType: firestoreData['selectedLoanType'] ?? 'Unknown',
    );
  }
}
