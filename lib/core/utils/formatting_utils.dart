String formatUSDT(String microAmount) {
  try {
    final amount = int.parse(microAmount) / 1000000;
    return '\$${amount.toStringAsFixed(3)}';
  } catch (e) {
    return '\$0.000';
  }
}

String formatDate(String timestamp) {
  try {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
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