part of 'albums_songs_bloc.dart';

sealed class AlbumsSongsState extends Equatable {
  const AlbumsSongsState();
  
  @override
  List<Object> get props => [];
}

class AlbumsSongsInitial extends AlbumsSongsState {}
class AlbumsSongsloading extends AlbumsSongsState {}
class AlbumsSongsloaded extends AlbumsSongsState {
  final List<AlbumSongEntity> songs;
  AlbumsSongsloaded({
    required this.songs,
  });
}
class playlistsongs extends AlbumsSongsState {
  final List<playlistEntity> songs;
  playlistsongs({
    required this.songs,
  });
}

class Songsfromalbum extends AlbumsSongsState {
  final List<SongModel> albumsongs;

  Songsfromalbum({required this.albumsongs});
}

