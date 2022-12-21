import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutterwave_payment/src/blocs/connection_bloc.dart';
import 'package:flutterwave_payment/src/common/strings.dart';
import 'package:flutterwave_payment/src/common/validator_utills.dart';
import 'package:flutterwave_payment/src/dto/charge_request_body.dart';
import 'package:flutterwave_payment/src/exception/exception.dart';
import 'package:flutterwave_payment/src/manager/base_transaction_manager.dart';

class AchTransactionManager extends BaseTransactionManager {
  AchTransactionManager(
      {required BuildContext context,
      required TransactionComplete onTransactionComplete})
      : super(
          context: context,
          onTransactionComplete: onTransactionComplete,
        );

  @override
  charge() async {
    setConnectionState(ConnectionState.waiting);
    try {
      var response = await service!.charge(
        ChargeRequestBody.fromPayload(
            payload: payload!..isUsBankCharge = true, type: "account"),
      );
      setConnectionState(ConnectionState.done);

      flwRef = response.flwRef;

      if (!response.hasData) {
        handleError(e: RaveException(data: Strings.noResponseData));
        return;
      }

      final authUrl = response.authUrl!;

      if (!ValidatorUtils.isUrlValid(authUrl)) {
        handleError(e: RaveException(data: Strings.noAuthUrl));
        return;
      }

      showWebAuthorization(authUrl);
    } on RaveException catch (e) {
      handleError(e: e);
    }
  }
}
