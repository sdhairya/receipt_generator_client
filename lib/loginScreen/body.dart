import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:receipt_generator_client/dashboardScreen/dashboardScreen.dart';
import 'package:receipt_generator_client/generateReceipt/generateReceipt.dart';
import 'package:receipt_generator_client/supabasehandler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components.dart';

class body extends StatefulWidget {
  const body({Key? key}) : super(key: key);

  @override
  State<body> createState() => _bodyState();
}

class _bodyState extends State<body> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isobscure = true;
  bool isLoading = false;
  bool _ischecked = false;

  @override
  void initState() {
    _loadUserEmailPassword();
    super.initState();
  }

  void _toggle() {
    setState(() {
      _isobscure = !_isobscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 100),
            child: Container(
              alignment: Alignment.center,
              constraints:
                  BoxConstraints(maxWidth: kIsWeb ? 500 : double.infinity),
              child: Center(
                  child: Padding(
                padding: EdgeInsets.only(left: 35, right: 35),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: components().text(
                          "Login", FontWeight.bold, Color(0xFF1D2A3A), 42),
                    ),
                    SizedBox(
                      height: 70,
                    ),
                    components()
                        .text("Email", FontWeight.normal, Colors.black26, 16),
                    components().textField("Enter Email id",
                        TextInputType.emailAddress, _emailController),
                    SizedBox(
                      height: 20,
                    ),
                    components().text(
                        "Password", FontWeight.normal, Colors.black26, 16),
                    TextFormField(
                      obscureText: _isobscure,
                      controller: _passwordController,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54)),
                          hintText: 'Enter Password',
                          suffixIcon: IconButton(
                            icon: Icon(_isobscure
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: _toggle,
                          )),
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text("Remember Me",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xff646464),
                            fontSize: 16,
                          )),
                      value: _ischecked,
                      onChanged: (value) {
                        _handleRememeberme(value!);
                      },
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF1D2A3A),
                          padding: EdgeInsets.all(3),
                          textStyle: TextStyle(fontSize: 20),
                          minimumSize: Size.fromHeight(50),
                          shape: StadiumBorder(),
                          enableFeedback: true,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                backgroundColor: Colors.transparent,
                              )
                            : const Text('LogIn'),
                        // onPressed:() {
                        //   Navigator.of(context).pushReplacement(
                        //               MaterialPageRoute(
                        //                   builder: (context) => generateReceipt()));
                        // },
                        onPressed: () async {
                          if (isLoading) return;

                          setState(() => isLoading = true);

                          if (_emailController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty) {
                            bool emailValid = RegExp(
                                    r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                .hasMatch(_emailController.text);

                            if (emailValid) {
                              List<String> resturant = await SupaBaseHandler().authUser(
                                  _emailController.text.toString(),
                                  _passwordController.text.toString());
                              _handleRememeberme(true);
                              print(resturant);
                              if (resturant != null) {

                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) => dashboardScreen(resturant: resturant),
                                ));
                              }
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text('Error'),
                                        content:
                                            Text("Please enter valid email!!"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Ok'))
                                        ],
                                      ));
                              setState(() => isLoading = false);
                            }
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('Error'),
                                      content:
                                          Text("All fields are required!!"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Ok'))
                                      ],
                                    ));
                            setState(() => isLoading = false);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRememeberme(bool value) async {
    _ischecked = value;
    SharedPreferences.getInstance().then(
          (prefs) {
        prefs.setBool("remember_me", value);
        prefs.setString('email', _emailController.text);
        prefs.setString('password', _passwordController.text);
      },
    );
    setState(() {
      _ischecked = value;
    });
  }

  _loadUserEmailPassword() async {
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      var _email = _prefs.getString("email") ?? "";
      var _password = _prefs.getString("password") ?? "";
      var _rememberMe = _prefs.getBool("remember_me") ?? false;

      if (_rememberMe) {
        setState(() {
          _ischecked = true;
        });
        _emailController.text = _email;
        _passwordController.text = _password;
        // bool emailValid = RegExp(
        //     r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        //     .hasMatch(_emailController.text);
        //
        // if (emailValid) {
        //   setState(() {
        //     isLoading = true;
        //   });
        //   List<String> resturant = await SupaBaseHandler().authUser(
        //       _emailController.text.toString(),
        //       _passwordController.text.toString());
        //   _handleRememeberme(true);
        //   print(resturant);
        //   if (resturant != null) {
        //
        //     Navigator.of(context)
        //         .pushReplacement(MaterialPageRoute(
        //       builder: (context) => dashboardScreen(resturant: resturant),
        //     ));
        //   }
        // } else {
        //   showDialog(
        //       context: context,
        //       builder: (context) => AlertDialog(
        //         title: Text('Error'),
        //         content:
        //         Text("Please enter valid email!!"),
        //         actions: [
        //           TextButton(
        //               onPressed: () {
        //                 Navigator.of(context).pop();
        //               },
        //               child: Text('Ok'))
        //         ],
        //       ));
        //   setState(() => isLoading = false);
        // }
      }
    } catch (e) {
      print(e);
    }
  }

}
