class TpDataModel {
  final Map<String, dynamic> transitPass;
  final int id;
  final int tpId;
  final int checkpointId;
  final String correctverificationcode;

  TpDataModel(
      {this.transitPass,
      this.id,
      this.checkpointId,
      this.correctverificationcode,
      this.tpId});

  factory TpDataModel.fromJson(Map<String, dynamic> json) {
    return TpDataModel(
        id: json['id'],
        checkpointId: json['checkpoint_id'],
        correctverificationcode: json['correct_verification_code'],
        tpId: json['tp_id'],
        transitPass: json['transit_pass']);
  }
}
