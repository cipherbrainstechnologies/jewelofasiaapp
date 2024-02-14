class CheckOutData{
  String? orderType;
  String? freeDeliveryType;
  double? amount;
  double? deliveryCharge;
  double? placeOrderDiscount;
  String? couponCode;
  String? orderNote;

  CheckOutData({
    required this.orderType,
    required this.freeDeliveryType,
    required this.amount,
    required this.deliveryCharge,
    required this.placeOrderDiscount,
    required this.couponCode,
    required this.orderNote,
  });

  CheckOutData copyWith({String? orderNote, double? discount, double? deliveryCharge}) {
    if(orderNote != null) {
      this.orderNote = orderNote;
    }
    if(discount != null) {
      placeOrderDiscount = discount;
    }
    if(deliveryCharge != null) {
      this.deliveryCharge = deliveryCharge;
    }
    return this;
  }


}