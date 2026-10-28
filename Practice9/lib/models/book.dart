class Book {
  const Book(this.title, this.author, this.price);
  final String title;
  final String author;
  final int price;
}

const books = [
  Book('Widgets All the Way Down', 'A. Nurmagambetova', 4200),
  Book('Null Safety for Humans', 'B. Seitkali', 3100),
  Book('Constraints Go Down, Sizes Go Up', 'C. Tashimova', 5600),
  Book('The Navigator Is a Stack', 'D. Alibekov', 2900),
  Book('Forms That Validate Themselves', 'E. Omarova', 3800),
  Book('Put It High, Subscribe Low', 'F. Kairatuly', 4700),
];
