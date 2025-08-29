class EbData{
  double fee;
  DateTime updateTime;

  EbData(this.fee, this.updateTime);
}

enum PayType{
  alipay,
  wechatpay,
}

abstract class AbstractEbGraber{
  Future<EbData?> grab(String url);

  Future<bool> chargeEb(String url, PayType type, double amount);
}