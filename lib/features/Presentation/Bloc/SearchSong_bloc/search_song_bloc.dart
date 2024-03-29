// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:nebula/features/Domain/Entity/AlbumDetailsEntity/AlbumDetailEntity.dart';
import 'package:nebula/features/Domain/Entity/LaunchDataEntity/LaunchDataEntity.dart';
import 'package:nebula/features/Domain/Entity/SearchSongEntity/SearchEntity.dart';
import 'package:nebula/features/Domain/UseCases/API_UseCase/GetSearchedAlbums_USeCase.dart';
import 'package:nebula/features/Domain/UseCases/API_UseCase/SearchPlaylist_UseCase.dart';
import 'package:nebula/features/Domain/UseCases/API_UseCase/SearchSong_UseCase.dart';

part 'search_song_event.dart';
part 'search_song_state.dart';

class SearchSongBloc extends Bloc<SearchSongEvent, SearchSongState> {
  final SearchSongUseCase useCase;
  final GetSearchedAlbumsUseCase getSearchedAlbumsUseCase;
  final SearchPlaylistUseCase playlistUseCase;
  SearchSongBloc(
    this.useCase,
    this.getSearchedAlbumsUseCase,
    this.playlistUseCase,
  ) : super(SearchSongInitial()) {
    on<GetSearchSong>((event, emit) async{
      emit(SearchSongLoading());
      List<SearchEntity> searchentity = await useCase.call(event.Querydata);
      List<AlbumSongEntity> albums = await getSearchedAlbumsUseCase.call(event.Querydata);
      List<launchdataEntity> playlists = await playlistUseCase.call(event.Querydata);
      emit(SearchSongLoaded(Seachsong: searchentity,albums: albums,playlists: playlists));
    });
  }
}
