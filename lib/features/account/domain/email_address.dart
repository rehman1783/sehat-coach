class EmailAddress {
  EmailAddress._(this.value);

  final String value;

  static EmailAddress parse(String input) {
    final value = input.trim();
    if (value.length > 254 || value.contains(RegExp(r'\s'))) {
      throw FormatException('Enter a valid email address');
    }
    final separator = value.indexOf('@');
    final valid =
        separator > 0 &&
        separator == value.lastIndexOf('@') &&
        separator < value.length - 3 &&
        value.indexOf('.', separator) > separator + 1 &&
        !value.endsWith('.');
    if (!valid) throw FormatException('Enter a valid email address');
    return EmailAddress._(value);
  }
}
