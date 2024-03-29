import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:nebula/configs/Error/Errors.dart';
import 'package:nebula/features/Domain/UseCases/yt_usecase/getaudiostream_usecase.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:nebula/configs/constants/Spaces.dart';
import 'package:nebula/features/Data/Models/songmodel.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:nebula/injection_container.dart' as di;
import '../../../Data/Models/onlinesongmodel.dart';
import '../../../Domain/Entity/AlbumDetailsEntity/AlbumDetailEntity.dart';
import '../../../Domain/Entity/PlaylistEntity/PlaylistEntity.dart';
import '../../../Domain/Entity/SearchSongEntity/SearchEntity.dart';

part 'audio_bloc.freezed.dart';
part 'audio_event.dart';
part 'audio_state.dart';


class AudioBloc extends Bloc<AudioEvent, AudioState> {
   AudioBloc() : super(const _Initial()) {

   //vr
    List<OnlineSongModel> onlinesongs = [];

    //forchecking
    List<OnlineSongModel> onlineaudiosforchecking = [];

    final onlineplayerstreamcontroller = BehaviorSubject<AudioState>();

    final parseytaudiocontroller = BehaviorSubject<OnlineSongModel>();

    late StreamSubscription subscribetoyt;

  //offlinechecking
  List<Songmodel> sourcesforchecking = [];

  //Mainsource
  List<AudioSource> audiosources = [];


  final localplayercontroller = BehaviorSubject<AudioState>();

  //Localsongmodel
  List<Songmodel> song = [];

  AudioPlayer audioPlayer = AudioPlayer();

  
  //Onlinesongmodel
  late  ConcatenatingAudioSource concatenatingAudioSource;


  clearall()async{
    song.clear();
    sourcesforchecking.clear();
    audiosources.clear();
    }
    


parse({
required List<Map<String,dynamic>> favsong,
required List<AlbumSongEntity> allsongs,
required List<SearchEntity> seachSongs,
required List<playlistEntity> playlistsongs,
required List<SongModel>localsongs,
required List<Video> ytaudios,
  })async{

   // Directory temp = await getTemporaryDirectory();

   if(localsongs.isNotEmpty){

    clearall();

    for (var element in localsongs) {
      if (element.uri != null) {

      Songmodel songmodel = Songmodel(id: element.id, title: element.displayNameWOExt, subtitle: element.artist ?? 'unkown', uri:element.uri!);
      song.add(songmodel);
      sourcesforchecking.add(songmodel);



         AudioSource source = AudioSource.uri(Uri.parse(element.uri!) ,tag: MediaItem(
         id: "${element.id}",
         title: element.displayNameWOExt,
         artist: element.artist,
        ));
        audiosources.add(source);
       }
      
    }  
      return;
  }else if(favsong.isNotEmpty){

      clearall();

     for (var element in favsong) { 

        Songmodel songmodel = Songmodel(id: int.parse(
        element['id']), 
        title: element['title'], 
        subtitle: element['artist'], 
        uri: element['uri']);
        song.add(songmodel);
        sourcesforchecking.add(songmodel);

         AudioSource source = AudioSource.uri(Uri.parse(element['uri']),tag: MediaItem(
         id: element['id'],
         title: element['title'],
         artist: element['artist'],
     //    artUri: Uri.directory(File("${temp.path}${element['id']}.jpg").path)
         ),);
         audiosources.add(source);
       }  
       return;
  }else if(allsongs.isNotEmpty){
     onlineaudiosforchecking.clear();
     onlinesongs.clear();

     for (var element in allsongs) {
      OnlineSongModel onlineSongModel = OnlineSongModel(
        id: element.id, 
        title: element.name, 
        imageurl: element.image, 
        downloadurl: element.songs, 
        artist: element.primaryArtists);
        onlinesongs.add(onlineSongModel);
        onlineaudiosforchecking.add(onlineSongModel);


     AudioSource source = AudioSource.uri(Uri.parse(element.songs),tag: MediaItem(
     id: element.id,
     title: element.name,
     artist: element.primaryArtists,
     artUri: Uri.parse(element.image)
     ));
     audiosources.add(source);
  }
  }else if(playlistsongs.isNotEmpty){
     onlineaudiosforchecking.clear();
     onlinesongs.clear();

     for (var element in playlistsongs) {
      OnlineSongModel onlineSongModel = OnlineSongModel(
        id: element.id, 
        title: element.name, 
        imageurl: element.images, 
        downloadurl: element.downloadUrl, 
        artist: element.primaryArtists);
        onlinesongs.add(onlineSongModel);
        onlineaudiosforchecking.add(onlineSongModel);


     AudioSource source = AudioSource.uri(Uri.parse(element.downloadUrl),tag: MediaItem(
     id: element.id,
     title: element.name,
     artist: element.primaryArtists,
     artUri: Uri.parse(element.images)
     ));
     audiosources.add(source);
  }

  }else if(seachSongs.isNotEmpty){
           onlineaudiosforchecking.clear();
     onlinesongs.clear();

     for (var element in seachSongs) {
      OnlineSongModel onlineSongModel = OnlineSongModel(
        id: element.id, 
        title: element.name, 
        imageurl: element.image, 
        downloadurl: element.downloadUrl, 
        artist: element.primaryArtists);
        onlinesongs.add(onlineSongModel);
        onlineaudiosforchecking.add(onlineSongModel);


     AudioSource source = AudioSource.uri(Uri.parse(element.downloadUrl),tag: MediaItem(
     id: element.id,
     title: element.name,
     artist: element.primaryArtists,
     artUri: Uri.parse(element.image)
     ));
     audiosources.add(source);
     }
    }
   }

      on<_Dispose>((event, emit) async{
      concatenatingAudioSource.clear();
      song.clear();
      sourcesforchecking.clear();
      await audioPlayer.dispose();
      emit(const AudioState.initial());
    });

    on<_Localaudio>((event, emit) async{
      state.mapOrNull(Localsongs: (value) => emit(value.copyWith(isloading: true)),);

      if(audiosources.isNotEmpty) {
       song.clear();
       sourcesforchecking.clear();
       onlineaudiosforchecking.clear();
       onlinesongs.clear(); 
       audiosources.clear();
      }

    
      await parse
      (favsong: event.favsongs, 
      allsongs: const [], 
      seachSongs: const [], 
      playlistsongs: const [], 
      localsongs: event.songs, ytaudios: []);

    if (audiosources.isNotEmpty) {

        var streams = Rx.combineLatest4(
        audioPlayer.playerStateStream,
        audioPlayer.currentIndexStream,
        audioPlayer.durationStream,
        audioPlayer.positionStream,
         (b, c,stat,pos) => AudioState.LocalStreams(pos, stat!,b,c!));

        streams.listen((event) {
         localplayercontroller.sink.add(event);
         }); 

       concatenatingAudioSource = ConcatenatingAudioSource(children: audiosources,useLazyPreparation: true); 
       emit(AudioState.Localsongs(false,false,song,localplayercontroller.stream,event.index,audioPlayer));
       await audioPlayer.setAudioSource(concatenatingAudioSource,initialIndex: event.index,initialPosition: Duration.zero,);
       // await audioPlayer.seek(Duration.zero,index: event.index);
       await audioPlayer.play();
    }
   });

   ///Online event
       on<_Onlineaudio>((event, emit) async{
        
       state.mapOrNull(onlinesongs: (value) => emit(value.copyWith(isloading:true)),);
 
      if(audiosources.isNotEmpty) {
       song.clear();
       song = [];
       sourcesforchecking.clear();
       song.clear();
       sourcesforchecking = [];
       audiosources.clear();
       audiosources = [];
      }



       await parse(
        favsong: const [], 
        allsongs: event.allsongs, 
        seachSongs: event.deachSongs, 
        playlistsongs: event.playlistsongs, 
        localsongs: const [], ytaudios: []);

        Stream<AudioState> streams = Rx.combineLatest5(
          audioPlayer.playerStateStream,
          audioPlayer.durationStream, 
          audioPlayer.positionStream, 
          audioPlayer.bufferedPositionStream, 
          audioPlayer.currentIndexStream, 
          (play,dur,pos,buf,playstate) => AudioState.onlinestreams(pos, dur!, play, buf,playstate!));
         
        streams.listen((event) {
            onlineplayerstreamcontroller.sink.add(event);
        });

        concatenatingAudioSource = ConcatenatingAudioSource(children: audiosources);
        emit(AudioState.onlinesongs(false,false,onlinesongs,onlineplayerstreamcontroller.stream,event.index, audioPlayer));
        await audioPlayer.setAudioSource(concatenatingAudioSource,initialIndex: event.index,initialPosition: Duration.zero);
        await audioPlayer.seek(Duration.zero,index: event.index);
        await audioPlayer.play();
    });

     on<_Parseytaudio>((event, emit) async{

        subscribetoyt = parseytaudiocontroller.doOnCancel(() {
         onlinesongs.clear();
         onlinesongs = [];
         onlineaudiosforchecking.clear();
         onlinesongs.clear();
         onlineaudiosforchecking = [];
         audiosources.clear();
         audiosources = [];
        }).listen(null);
        

        for (var i = 0; i < event.videos.length; i++) {
           if (event.currentvideo.id == event.videos[i].id) {
             continue;
           }
           else
           {
                  Video details = event.videos[i];
                  StreamManifest streamManifest = await YoutubeExplode().videos.streamsClient.getManifest(details.id);

                  final List<AudioOnlyStreamInfo> sortedStreamInfo = streamManifest.audioOnly
                  .toList()
                  ..sort((a, b) => a.bitrate.compareTo(b.bitrate));

                  final audio = sortedStreamInfo.where((element) => element.audioCodec.contains('mp4'));
 
                  AudioOnlyStreamInfo next = audio.reduce((value, element) => value.size.totalBytes > element.size.totalBytes ? value:element);    
                
                  OnlineSongModel onlineSongModel = OnlineSongModel(
                    id: details.id.toString(), 
                    title: details.title, 
                    imageurl:details.thumbnails.maxResUrl, 
                    downloadurl: next.url.toString(), 
                    artist: details.author);

                  parseytaudiocontroller.sink.add(onlineSongModel);  
           }
        }

     });

      on<_Ytaudio>((event, emit) async{

       emit(AudioState.youtubesong(true,false,onlinesongs,onlineplayerstreamcontroller.stream,0, audioPlayer));

       if(onlinesongs.isNotEmpty)
        {
         onlinesongs.clear();
         onlinesongs = [];
         onlineaudiosforchecking.clear();
         onlinesongs.clear();
         onlineaudiosforchecking = [];
         audiosources.clear();
         audiosources = [];
        }

        parseytaudiocontroller.hasListener?await subscribetoyt.cancel():null;

        add(_Parseytaudio(event.audios,true,event.audios[event.index])); 
       
        Either<Failures,AudioStreamInfo> getaudiostream = await di.di<Getaudiostreamusecase>().call(event.audios[event.index].id.toString());

        await getaudiostream.fold((l) {}, (r) async{

        AudioSource source = AudioSource.uri(r.url,tag: MediaItem(
        id: event.audios[event.index].id.toString(),
        artist: event.audios[event.index].author,
        artUri: Uri.parse(event.audios[event.index].thumbnails.highResUrl),
        title: event.audios[event.index].title.toString()));

       OnlineSongModel onlineSongModel = OnlineSongModel(
       id: event.audios[event.index].id.toString(), 
       title: event.audios[event.index].title,
       imageurl: event.audios[event.index].thumbnails.maxResUrl,
       downloadurl: r.url.toString(),
       artist: event.audios[event.index].author);
       onlineaudiosforchecking.add(onlineSongModel);
       onlinesongs.add(onlineSongModel);

          Stream<AudioState> streams = Rx.combineLatest5(
          audioPlayer.playerStateStream,
          audioPlayer.durationStream, 
          audioPlayer.positionStream, 
          audioPlayer.bufferedPositionStream, 
          audioPlayer.currentIndexStream, 
          (play,dur,pos,buf,playstate) 
          =>
          AudioState.youtubestreams(pos, dur!, play, buf,playstate!));

       streams.listen((event) {
           onlineplayerstreamcontroller.add(event);
       });

       concatenatingAudioSource = ConcatenatingAudioSource(children: [
        source
       ]);

       emit(AudioState.youtubesong(false,false,onlinesongs,onlineplayerstreamcontroller.stream,0, audioPlayer));
       await audioPlayer.setAudioSource(concatenatingAudioSource,initialIndex:0,initialPosition: Duration.zero);
       await audioPlayer.play();


       subscribetoyt.onData((data) async{
        if (onlinesongs.any((element) => element.id == data.id)) {
          return;
        } else {
          await concatenatingAudioSource.add(AudioSource.uri(Uri.parse((data as OnlineSongModel).downloadurl)
          ,tag: MediaItem(
            id: data.id,
            artist: data.artist,
            artUri: Uri.parse(data.imageurl),
            title: data.title)
          ));
          onlinesongs.add(data);
        }
       });
      }
      );  
     }, 
     );


    on<_Pause>((event, emit)async =>await audioPlayer.pause());

    on<_Resume>((event, emit) async=> await audioPlayer.play());

    on<_Loopon>((event, emit) async=>await audioPlayer.setLoopMode(event.islooped?LoopMode.one:LoopMode.off));

    on<_Shuffleon>((event, emit) async=>await audioPlayer.setShuffleModeEnabled(event.isshuffled?true:false));

    on<_Seeknextaudio>((event, emit) async=>await audioPlayer.seekToNext());

    on<_Seekpreviousaudio>((event, emit) async=> await audioPlayer.seekToPrevious());

    on<_Updatequeue>((event, emit) async{
       if (event.mode == 'online') {
       final item = onlinesongs.removeAt(event.oldindex);
       onlinesongs.insert(event.newindex,item);
       final forchecking = onlineaudiosforchecking.removeAt(event.oldindex);
       onlineaudiosforchecking.insert(event.newindex,forchecking);
       concatenatingAudioSource.move(event.oldindex,event.newindex);
       } else {
       final item = song.removeAt(event.oldindex);
       song.insert(event.newindex,item);
       final forchecking = sourcesforchecking.removeAt(event.oldindex);
       sourcesforchecking.insert(event.newindex,forchecking);
       await concatenatingAudioSource.move(event.oldindex,event.newindex);
       }
      });

      on<_Removefromqueue>((event, emit) async{
       if (event.mode == 'online') {
       onlinesongs.removeAt(event.indextoberemoved);
       onlineaudiosforchecking.removeAt(event.indextoberemoved);
       await concatenatingAudioSource.removeAt(event.indextoberemoved);        
       } else {
       sourcesforchecking.removeAt(event.indextoberemoved);
       song.removeAt(event.indextoberemoved);
       await concatenatingAudioSource.removeAt(event.indextoberemoved);             
       }
    });

    on<_Addsongtoqueue>((event, emit) async{
         if (onlinesongs.isNotEmpty) {
           Spaces.showtoast(" Can't add Offline songs to Online Queue");
         } else {
         Directory temp = await getTemporaryDirectory();
         String tempDirectory = "${temp.path}${event.song.id}.jpg";
         File file = File(tempDirectory);
         String songuri = event.song.uri;
         AudioSource source = AudioSource.uri(Uri.parse(songuri),tag: MediaItem(
         id:event.song.id.toString(),
         title: event.song.title,
         artist: event.song.subtitle,
         artUri: Uri.directory(file.path)
         ),);

         bool isexist = sourcesforchecking.any((element) => element.id == event.song.id);

         if(isexist) {
           Spaces.showtoast('added already');
         } else {
          sourcesforchecking.add(event.song);
          song.add(event.song);
          await concatenatingAudioSource.add(source);
         }
            }
    });

    on<_AddtoOnlinequeue>((event, emit) async{

          if (song.isNotEmpty) {
            Spaces.showtoast("Can't add Online songs to Offline queue");
          } else {
            
         AudioSource source = AudioSource.uri(Uri.parse(event.song.downloadurl),tag: MediaItem(
         id:event.song.id.toString(),
         title: event.song.title,
         artist: event.song.artist,
         artUri: Uri.parse(event.song.imageurl)
         ),);

         bool isexist = onlineaudiosforchecking.any((element) => element.id == event.song.id);

         if(isexist) {
           Spaces.showtoast('added already');
         } else {
          onlineaudiosforchecking.add(event.song);
          onlinesongs.add(event.song);
          await concatenatingAudioSource.add(source);
         }
          }
        
    });

    on<_Clearqueueexceptplaying>((event, emit) async{
        if (event.mode == 'online') {
        for (var i = concatenatingAudioSource.length - 1; i >= 0; i--) {
        if (i == event.currentplaying) {
          continue;
          } else {
          onlineaudiosforchecking.removeAt(i);
          onlinesongs.removeAt(i);
          concatenatingAudioSource.removeAt(i);
         }
         }
        } else {
         for (var i = concatenatingAudioSource.length - 1; i >= 0; i--) {
        if (i == event.currentplaying) {
          continue;
          } else {
          sourcesforchecking.removeAt(i);
          song.removeAt(i);
          concatenatingAudioSource.removeAt(i);
         }
         }
        }
    });
  }
}
