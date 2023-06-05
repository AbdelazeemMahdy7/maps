import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:maps/constants/my_colors.dart';
import 'package:maps/constants/strings.dart';

class LoginScreen extends StatelessWidget {
  late String phoneNumber;
  final GlobalKey<FormState> phoneFormKey = GlobalKey();

  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: phoneFormKey,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 90),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildIntroTexts(),
                const SizedBox(
                  height: 100,
                ),
                buildPhoneFormField(),
                const SizedBox(
                  height: 60,
                ),
                buildNextButtom(context),
                buildPhoneNumberSubmitedBloc(),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget buildIntroTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What is your phone number?",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: const Text(
            "Please Enter your phone number to verify to account. ",
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPhoneFormField() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: MyColors.lightGrey),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            child: Text(
              '${generateCountryFlage()}+20',
              style: const TextStyle(
                fontSize: 18,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: MyColors.blue),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            child: TextFormField(
              autofocus: true,
              style: const TextStyle(
                fontSize: 18,
                letterSpacing: 2.0,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              cursorColor: Colors.black,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please Enter your phone number";
                } else if (value.length < 11) {
                  return "Too short for Phone Number";
                }
                return null;
              },
              onSaved: (value) {
                phoneNumber = value!;
              },
            ),
          ),
        ),
      ],
    );
  }

  String generateCountryFlage() {
    String countryCode = "eg";
    String flag = countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
    return flag;
  }

  Future<void>_register(context)async{
    if(!phoneFormKey.currentState!.validate()){
      Navigator.pop(context);
      return ;
    }else{
      Navigator.pop(context);
      phoneFormKey.currentState!.save();
      BlocProvider.of<PhoneAuthCubit>(context).submitPhoneNumber(phoneNumber);
    }
  }

  Widget buildNextButtom(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton(
        onPressed: () {
          // Navigator.pushReplacementNamed(context, otpScreen);
          showProgressIndicator(context);
          _register(context);
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(110, 50),
          primary: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          "Next",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget buildPhoneNumberSubmitedBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthStates>(
      listenWhen: (pervious, current) {
        return pervious != current;
      },
      listener: (context, state) {
        if (state is PhoneLoading) {
          showProgressIndicator(context);
        }
        if (state is PhoneNumberSubmited) {
          Navigator.pop(context);
          Navigator.pushNamed(context, otpScreen, arguments: phoneNumber);
        }
        if (state is PhoneOccurredErorr) {
          String erorrMsg = (state).erorrMsg;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(erorrMsg),
            backgroundColor: Colors.black,
            duration: const Duration(milliseconds: 2500),
          ),
          );
        }
      },
      child: Container(),
    );
  }

  void showProgressIndicator(BuildContext context) {
    AlertDialog alertDialog = const AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      content: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.black,
          ),
        ),
      ),
    );
    showDialog(
        barrierColor: Colors.white.withOpacity(0.0),
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return alertDialog;
        });
  }
}
