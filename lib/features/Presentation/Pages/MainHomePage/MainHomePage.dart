import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nebula/features/Presentation/CustomWidgets/musicbottombarloading.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nebula/injection_container.dart' as dii;
import '../../../../configs/constants/Spaces.dart';
import '../../../Domain/UseCases/Platform_UseCase/GetPermissions_UseCase.dart';
import '../../../Domain/UseCases/Sql_UseCase/initializedatabase_Usecase.dart';
import '../../Blocs/Musicbloc/LocalSongs_bloc/localsong_bloc.dart';
import '../../Blocs/Musicbloc/Trending_Song_bloc/trending_song_bloc.dart';
import '../../Blocs/Musicbloc/audio_bloc/audio_bloc.dart';
import '../../Blocs/Musicbloc/favorite_bloc/favoriteplaylist_bloc.dart';
import '../../Blocs/Musicbloc/playlist_Bloc/playlist_bloc.dart';
import '../../Blocs/youtubeBloc/ytsearch_bloc/ytsearch_bloc.dart';
import '../../CustomWidgets/backgroundGradient.dart';
import '../../CustomWidgets/muscibottombarwidget.dart';
import '../saavn/Aboutpage/aboutpage.dart';
import '../saavn/DownloadPages/Downloadpages.dart';
import '../saavn/HomePage.dart';
import '../saavn/MySongPage.dart';
import '../saavn/Settings/settingspage.dart';
import '../saavn/musicplayerpage/testonlineplayerscreen.dart';
import '../saavn/musicplayerpage/testplayerscreen.dart';
import '../saavn/onlinefavepage.dart';
import '../saavn/subscreens/youtubescreen/ytpage.dart';
import '../saavn/subscreens/ytsearchpage/ytsearchpage.dart';

bool islooped = false;
bool isSuffled = false;


class MainHomePage extends StatefulWidget {
  static const String mainHomePAge = '/mainhomepage';
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int currentindex = 0;

  List<Widget> pages = [
    const HomePage(),
    const MySongPage(),
    const Youtubepage(),
    const Onlinefavscreen()
  ];

  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState!.closeDrawer();
  }

  void call() async {
    BlocProvider.of<YtsearchBloc>(context).add(const YtsearchEvent.freestate());
    BlocProvider.of<PlaylistBloc>(context)
        .add(const PlaylistEvent.getallplaylist());
    BlocProvider.of<FavoriteplaylistBloc>(context)
        .add(const FavoriteplaylistEvent.getallsongs());
    BlocProvider.of<TrendingSongBloc>(context).add(TrendingSongs());
  }

  getpermission() async {
    try {
      await dii.di<initializedbusecase>().call();
      bool check =
          await dii.di<GetpermissionUseCase>().call().then((value) async {
        call();
        await _getallsongs();
        return value ? value : false;
      });
      if (check != true) {
        Spaces.showtoast(
            'Some Permissions are not Granted Some App Features May not work');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  _getallsongs() {
    BlocProvider.of<LocalsongBloc>(context)
    .add(const LocalsongEvent.getallsongs());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getpermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: currentindex == 0
            ? const Textutil(
                text: 'Discover',
                fontsize: 23,
                color: Colors.white,
                fontWeight: FontWeight.bold)
            : currentindex == 1
                ? const Textutil(
                    text: 'My Music',
                    fontsize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)
                : currentindex == 2
                        ? InkWell(
                          onTap: () {
                            Navigator.pushNamed(context,Ytsearchpage.ytsearchpage);
                          },
                          child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10,),
                                          Image.asset(
                                            'assets/yt.png',
                                            scale: 19,
                                          ),
                                          const SizedBox(width: 10,),
                                          const Textutil(text: 'Search on Youtube', fontsize: 15, color: Colors.grey, fontWeight:FontWeight.w400)
                                      ],
                                    )
                                  ),
                                )
                              ],
                            ),
                        )
                        : null,
        leading: InkWell(
            onTap: () => openDrawer(),
            child: Image.asset(
              'assets/list.png',
              color: Colors.white,
              scale: 25,
            )),
      ),
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: SalomonBottomBar(
          onTap: (p0) {
            setState(() {
              currentindex = p0;
            });
          },
          currentIndex: currentindex,
          selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
          backgroundColor: Colors.black,
          selectedColorOpacity: 0.1,
          unselectedItemColor: Colors.grey.withOpacity(0.5),
          itemPadding: const EdgeInsets.all(12),
          items: [
            SalomonBottomBarItem(
                icon: const Icon(Icons.home),
                title: Text(
                  'Discover',
                  style: Spaces.Getstyle(11, Colors.white, FontWeight.normal),
                )),
            SalomonBottomBarItem(
                icon: const Icon(Icons.folder_outlined),
                title: Text(
                  'Device',
                  style: Spaces.Getstyle(11, Colors.white, FontWeight.normal),
                )),
             SalomonBottomBarItem(
                icon: SizedBox(
                  width: 26,
                  height: 26,
                  child: Center(
                    child: Image.asset(
                      'assets/yt.png',
                      filterQuality: FilterQuality.low,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                title: Text(
                  'Youtube',
                  style: Spaces.Getstyle(10, Colors.white, FontWeight.normal),
                )),
                 SalomonBottomBarItem(
                icon: const Icon(Icons.my_library_music),
                title: Text(
                  'Library',
                  style: Spaces.Getstyle(10, Colors.white, FontWeight.normal),
                )),
                
          ]),
      body: Stack(
        children: [
          const backgroundgradient(),
          pages[currentindex],
          const Align(
              alignment: Alignment.bottomCenter, child: BottomMusicBar()),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.black.withOpacity(0.9),
        surfaceTintColor: Colors.transparent,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height / 4,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                              width: double.infinity,
                              child: Image.asset(
                                'assets/sound-wave.png',
                                fit: BoxFit.fill,
                                color: const Color.fromARGB(255, 157, 157, 157)
                                    .withOpacity(0.1),
                              )),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'NEBULA',
                                style: GoogleFonts.aldrich(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'v 1.0.1',
                                style: Spaces.Getstyle(
                                    10,
                                    Colors.white.withOpacity(0.7),
                                    FontWeight.normal),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  Column(
                    children: [
                      Draweritems(
                          ontap: () {
                            currentindex = 0;
                            setState(() {});
                            closeDrawer();
                          },
                          title: "Home",
                          iconsdata: Icons.home),
                      Draweritems(
                          ontap: () {
                            currentindex = 3;
                            setState(() {});
                            closeDrawer();
                          },
                          title: "My Library",
                          iconsdata: Icons.library_music_outlined),
                      Draweritems(
                          ontap: () {
                            Navigator.pushNamed(
                                context, Downloadpage.Downloadscreen);
                          },
                          title: "Downloads",
                          iconsdata: Icons.download),
                      Draweritems(
                          ontap: () {
                            Navigator.pushNamed(
                                context, Settingpage.settingpage);
                          },
                          title: "Settings",
                          iconsdata: Icons.settings),
                      Draweritems(
                          ontap: () {
                            Navigator.pushNamed(context, Aboutpage.aboutpage);
                          },
                          title: "About",
                          iconsdata: Icons.info_outline_rounded),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Build with ",
                  style: Spaces.Getstyle(10, Colors.white, FontWeight.normal),
                ),
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 12,
                ),
                Text(
                  ' by Adarsh N S ',
                  style: Spaces.Getstyle(10, Colors.white, FontWeight.normal),
                ),
              ],
            ),
            Spaces.Kheight20,
          ],
        ),
      ),
    );
  }
}

class Draweritems extends StatelessWidget {
  final VoidCallback ontap;
  final String title;
  final IconData iconsdata;
  const Draweritems({
    Key? key,
    required this.ontap,
    required this.title,
    required this.iconsdata,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: ListTile(
        leading: Icon(
          iconsdata,
          color: Colors.white,
          size: 21,
        ),
        title: Text(title,
            style: GoogleFonts.aldrich(color: Colors.white, fontSize: 15)),
      ),
    );
  }
}

class BottomMusicBar extends StatelessWidget {
  const BottomMusicBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        return state.maybeWhen(
            onlinesongs:
                (isloading, isfailed, audios, valueStream, index, audioPlayer) {
              return isloading == true
                  ? const MusicBottomBarloading()
                  : StreamBuilder(
                      stream: valueStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          int songindex = snapshot.data!.maybeMap(
                              orElse: () => 0,
                              onlinestreams: (val) => val.index);

                          PlayerState dupplayerstate =
                              PlayerState(false, ProcessingState.loading);

                          PlayerState playerState = snapshot.data!.maybeMap(
                            orElse: () => dupplayerstate,
                            onlinestreams: (value) => value.playerState,
                          );

                          return MusicbottombarWidget(
                            ontap: () {
                              Navigator.pushNamed(context,
                                  Onlineplayerscreen.onlineplayerscreen);
                            },
                            type: 'online',
                            songindex: songindex,
                            playerState: playerState,
                            audioPlayer: audioPlayer,
                            audios: audios,
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    );
            },
            Localsongs:
                (isloading, isfailed, audios, valueStream, index, audioPlayer) {
              return isloading == true
                  ? const MusicBottomBarloading()
                  : StreamBuilder(
                      stream: valueStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          PlayerState player =
                              PlayerState(true, ProcessingState.loading);

                          PlayerState playerState = snapshot.data!.maybeMap(
                            orElse: () => player,
                            LocalStreams: (value) => value.playerState,
                          );

                          int songindex = snapshot.data!.maybeMap(
                            orElse: () => 0,
                            LocalStreams: (value) => value.index,
                          );

                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, Testplayerscreen.textscreen,
                                  arguments: 'okey ');
                            },
                            child: Container(
                              height: 70,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(0),
                                  gradient: Spaces.musicgradient()),
                              child: Center(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.transparent,
                                    child: Hero(
                                      tag: '0',
                                      child: QueryArtworkWidget(
                                        id: audios[songindex].id,
                                        artworkQuality: FilterQuality.low,
                                        type: ArtworkType.AUDIO,
                                        artworkBlendMode: BlendMode.plus,
                                        artworkClipBehavior: Clip.antiAlias,
                                        keepOldArtwork: true,
                                        format: ArtworkFormat.JPEG,
                                        artworkBorder: BorderRadius.circular(9),
                                        nullArtworkWidget: Shimmer(
                                            gradient: const LinearGradient(
                                                colors: [
                                                  Colors.grey,
                                                  Colors.white
                                                ]),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            )),
                                      ),
                                    ),
                                  ),
                                  title: SizedBox(
                                    height: 20,
                                    width: 150,
                                    child: Textutil(
                                        text: audios[songindex].title,
                                        fontsize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: SizedBox(
                                    height: 12,
                                    width: 100,
                                    child: Textutil(
                                        text: audios[songindex].subtitle,
                                        fontsize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  trailing: SizedBox(
                                    width: 150,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              BlocProvider.of<AudioBloc>(
                                                      context)
                                                  .add(const AudioEvent
                                                      .SeekPreviousAudio());
                                            },
                                            icon: Icon(
                                              CupertinoIcons.backward_end_fill,
                                              color: audioPlayer.hasPrevious
                                                  ? Colors.white
                                                  : Colors.grey,
                                              size: 15,
                                            )),
                                        GestureDetector(
                                          onTap: () {
                                            playerState.playing == true
                                                ? BlocProvider.of<AudioBloc>(
                                                        context)
                                                    .add(const AudioEvent
                                                        .pause())
                                                : BlocProvider.of<AudioBloc>(
                                                        context)
                                                    .add(const AudioEvent
                                                        .resume());
                                          },
                                          child: Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                color: Colors.white),
                                            child: Icon(
                                              playerState.playing == true
                                                  ? CupertinoIcons.pause
                                                  : CupertinoIcons.play_arrow,
                                              color: Colors.black,
                                              size: 19,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              BlocProvider.of<AudioBloc>(
                                                      context)
                                                  .add(const AudioEvent
                                                      .seeknextaudio());
                                            },
                                            icon: Icon(
                                              CupertinoIcons.forward_end_fill,
                                              color: audioPlayer.hasNext
                                                  ? Colors.white
                                                  : Colors.grey,
                                              size: 15,
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    );
            },
            orElse: () => const SizedBox());
      },
    );
  }
}

class Loadingcustomgradient extends StatelessWidget {
  const Loadingcustomgradient({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      width: 150,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 81, 81, 81),
          borderRadius: BorderRadius.circular(20)),
    );
  }
}
