class DeliveryDatesModel {
  List<String>? expectedDates;

  DeliveryDatesModel({this.expectedDates});

  DeliveryDatesModel.fromJson(Map<String, dynamic> json) {
    expectedDates = json['expected_dates'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['expected_dates'] = this.expectedDates;
    return data;
  }
}
