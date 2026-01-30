import 'package:event/event.dart';
import '../basic/entities.dart';

var isPro = true;
var isProEx = 4102444800;

ProInfoAf? _proInfoAf;
ProInfoPat? _proInfoPat;

ProInfoAf get proInfoAf =>
    _proInfoAf ??
    ProInfoAf.fromJson({"is_pro": true, "expire": 4102444800});
ProInfoPat get proInfoPat => _proInfoPat ??
    ProInfoPat.fromJson({
      "is_pro": false,
      "pat_id": "",
      "bind_uid": "",
      "request_delete": 0,
      "re_bind": 0,
      "error_type": 0,
      "error_msg": "",
      "access_key": ""
    });

final proEvent = Event();

Future reloadIsPro() async {
  // Default to permanent pro status.
  _proInfoAf = ProInfoAf.fromJson({"is_pro": true, "expire": 4102444800});
  _proInfoPat ??= ProInfoPat.fromJson({
    "is_pro": false,
    "pat_id": "",
    "bind_uid": "",
    "request_delete": 0,
    "re_bind": 0,
    "error_type": 0,
    "error_msg": "",
    "access_key": ""
  });

  isPro = true;
  isProEx = 4102444800;

  proEvent.broadcast();
}
