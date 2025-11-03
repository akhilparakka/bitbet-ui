String formatDate(String timestamp) {
  try {
    final date = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp) * 1000,
    );
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$month/$day/$year $hour:$minute';
  } catch (e) {
    return 'Invalid Date';
  }
}

String formatShares(String shares) {
  try {
    final num = int.parse(shares);
    return num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  } catch (e) {
    return '0';
  }
}

String getOutcomeName(int outcomeIndex, List<String> outcomes) {
  if (outcomeIndex < outcomes.length) {
    return outcomes[outcomeIndex];
  }
  return 'Unknown';
}

// Format wei amounts (18 decimals) to human-readable format
String formatWeiAmount(String weiAmount) {
  try {
    final amount = BigInt.parse(weiAmount).toDouble() / 1e18;
    return amount.toStringAsFixed(6);
  } catch (e) {
    return '0.000000';
  }
}

// Format wei amounts as currency (18 decimals)
String formatWeiToCurrency(String weiAmount) {
  try {
    final amount = BigInt.parse(weiAmount).toDouble() / 1e18;
    return '\$${amount.toStringAsFixed(2)}';
  } catch (e) {
    return '\$0.00';
  }
}

// Convert wei string to double (18 decimals)
double weiToDouble(String weiAmount) {
  try {
    return BigInt.parse(weiAmount).toDouble() / 1e18;
  } catch (e) {
    return 0.0;
  }
}
