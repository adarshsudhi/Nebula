import 'package:dio/dio.dart';
import 'package:nebula/features/Domain/Repositorys/APIRepository/APIrepository.dart';

class DownloadArworkUseCase {
  final APIRepository repository;
  DownloadArworkUseCase({
    required this.repository,
  });
  Future<void>call(String DownloadUrl,ProgressCallback progressCallback,String artwokpath)async{
  return repository.DownloadArtwork(DownloadUrl, (count, total) { }, artwokpath);
}
}

