import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:gmaps/main.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  Home({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Stack(
        children: <Widget>[
          Pinned.fromPins(
            Pin(start: -126.0, end: 0.0),
            Pin(size: 543.0, start: -369.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x7e3d8c95),
                borderRadius:
                    BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(start: 55.0, end: 55.0),
            Pin(size: 43.0, middle: 0.6818),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(width: 1.0, color: const Color(0xffe6873c)),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(start: 55.0, end: 55.0),
            Pin(size: 43.0, middle: 0.786),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(width: 1.0, color: const Color(0xffe6873c)),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(start: 55.0, end: 55.0),
            Pin(size: 60.0, end: 80.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xff3d8c95),
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 101.0, start: 55.0),
            Pin(size: 20.0, middle: 0.6291),
            child: Text(
              'Username',
              style: TextStyle(
                // fontFamily: 'Hiragino Kaku Gothic ProN',
                fontSize: 20,
                color: const Color(0xff707070),
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 96.0, start: 55.0),
            Pin(size: 20.0, middle: 0.734),
            child: Text(
              'Password',
              style: TextStyle(
                // fontFamily: 'Hiragino Kaku Gothic ProN',
                fontSize: 20,
                color: const Color(0xff707070),
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 88.0, middle: 0.4971),
            Pin(size: 32.0, end: 93.0),
            child: Text(
              'Login',
              style: TextStyle(
                fontFamily: 'Hiragino Kaku Gothic ProN',
                fontSize: 20,
                color: const Color(0xffffffff),
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(start: 0.8, end: -75.2),
            Pin(size: 352.9, middle: 0.3333),
            child: Transform.rotate(
              angle: 0.0698,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage(''),
                    fit: BoxFit.fill,
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.76), BlendMode.dstIn),
                  ),
                ),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 546.0, end: -397.0),
            Pin(size: 530.0, start: -124.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x7f3d8c95),
                borderRadius:
                    BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
