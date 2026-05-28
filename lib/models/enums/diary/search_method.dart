enum SearchMethod {

  byMessage("В сообщении"),
  byTag("По тегу");

  final String label;
  const SearchMethod(this.label);
}