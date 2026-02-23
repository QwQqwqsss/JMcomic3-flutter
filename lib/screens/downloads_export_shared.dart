import 'package:jmcomic3/basic/methods.dart';

typedef DownloadAlbumFilter = bool Function(DownloadAlbum album);

Future<List<DownloadAlbum>> loadDownloadAlbums(DownloadAlbumFilter filter) async {
  final all = await methods.allDownloads();
  return all.where(filter).toList(growable: false);
}

List<int> restoreSelectedIds(
  List<int> previousSelected,
  List<DownloadAlbum> latest,
) {
  final latestIds = latest.map((e) => e.id).toSet();
  return previousSelected.where(latestIds.contains).toList(growable: false);
}
