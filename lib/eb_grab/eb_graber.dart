class EbData{
  double fee;
  DateTime updateTime;

  EbData(this.fee, this.updateTime);
}

class AbstractEbGraber{
  Future<EbData?> grab() async{
    throw UnimplementedError(); 
  }
}