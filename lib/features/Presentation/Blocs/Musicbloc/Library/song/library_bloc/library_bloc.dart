import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nebula/features/Domain/Entity/MusicEntity/AlbumDetailsEntity/AlbumDetailEntity.dart';
import 'package:nebula/features/Domain/Entity/MusicEntity/SongsDetailsEntity/SongsEntity.dart';
import 'package:nebula/features/Domain/UseCases/Sql_UseCase/getlibrarysong_usecase.dart';
import 'package:nebula/injection_container.dart' as di;
import '../../../../../../../configs/Error/Errors.dart';

part 'library_event.dart';
part 'library_state.dart';
part 'library_bloc.freezed.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc() : super(const _Initial()) {
    on<_Getlibrarysong>((event, emit) async{
        Either<Failures,List<Map<String,dynamic>>> res = await di.di<Getlibraryusecase>().call();
        await res.fold((l) {
         log('Failed');
          emit(const LibraryState.librarysong([]));
      }, (r) async{
        if (r.isEmpty) {
          emit(const LibraryState.librarysong([]));
        } else {
          emit(LibraryState.librarysong(r));
        }
      });
    });
    
  }
}
