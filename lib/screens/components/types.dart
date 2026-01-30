
import '../../basic/entities.dart';

class LongPressMenuItem {
  final String title;
  final Function() onChoose;

  LongPressMenuItem(this.title, this.onChoose);
}

class ComicLongPressMenuItem {
  final String title;
  final Function(ComicBasic comic) onChoose;

  ComicLongPressMenuItem(this.title, this.onChoose);
}