import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nebula/configs/constants/Spaces.dart';
import 'package:nebula/features/Presentation/Blocs/Musicbloc/LocalSongs_bloc/localsong_bloc.dart';
import '../../CustomWidgets/bgblur.dart';
import 'subscreens/Mymusic/album.dart';
import 'subscreens/Mymusic/playlist.dart';
import 'subscreens/Mymusic/songs.dart';

class MySongPage extends StatefulWidget {
  const MySongPage({super.key});

  @override
  State<MySongPage> createState() => _MySongPageState();
}

class _MySongPageState extends State<MySongPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const BGblur(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.sizeOf(context).height,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.9),
                        Colors.transparent.withOpacity(0.6)
                      ])),
                ),
              ),
              SizedBox(
                child: SafeArea(
                  child: Column(
                    children: [
                      Spaces.kheight10,
                      TabBar(
                          dividerColor: Colors.transparent,
                          indicatorColor: Colors.white,
                          labelStyle: Spaces.Getstyle(
                              12, Colors.black, FontWeight.bold),
                          labelColor: const Color.fromARGB(255, 255, 255, 255),
                          unselectedLabelColor:
                              const Color.fromARGB(255, 69, 69, 69),
                          indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.transparent),
                          tabs: const [
                            Text("SONGS"),
                            Text('ALBUMS'),
                            Text("PLAYLISTS")
                          ]),
                      Expanded(
                        child: TabBarView(children: [
                          BlocBuilder<LocalsongBloc, LocalsongState>(
                            builder: (context, state) {
                              return state.maybeWhen(
                                  songs: (songlist, albums, isloading, failed) {
                                return Songwidget(count: songlist.length);
                              }, orElse: () {
                                return const SizedBox(
                                  child: Center(
                                    child: Textutil(
                                        text: 'No Songs Found',
                                        fontsize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              });
                            },
                          ),
                          BlocBuilder<LocalsongBloc, LocalsongState>(
                            builder: (context, state) {
                              return state.maybeWhen(
                                  songs: (songlist, albums, isloading, failed) {
                                return AlbumWidget(count: albums.length);
                              }, orElse: () {
                                return const SizedBox(
                                  child: Center(
                                    child: Textutil(
                                        text: 'No Songs Found',
                                        fontsize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              });
                            },
                          ),
                          PlaylistWidget(size: size, controller: _controller)
                        ]),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
