/*
import 'package:flutter/material.dart';
import 'package:masterstudy_app/main.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

class PaywalWidget extends StatefulWidget {
  final String title;
  final String description;
  final List<Package> packages;
  final ValueChanged<Package> onClickPackage;

  const PaywalWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.packages,
    required this.onClickPackage,
  }) : super(key: key);

  @override
  State<PaywalWidget> createState() => _PaywalWidgetState();
}

class _PaywalWidgetState extends State<PaywalWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(child: Text(widget.title)),
            Center(child: Text(widget.description)),
            _buildPackages(),
          ],
        ),
      ),
    );
  }

  Widget _buildPackages() => ListView.builder(
        itemCount: widget.packages.length,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (BuildContext ctx, int index) {
          final package = widget.packages[index];
          return GestureDetector(
            onTap: () => widget.onClickPackage(package),
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      package.product.title,
                      style: TextStyle(
                        color: mainColor,
                      ),
                    ),
                  ),
                  Text('Price: ${package.product.priceString}'),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: mainColor,
                    ),
                    onPressed: () => widget.onClickPackage(package),
                    child: Text(
                      'Buy Product',
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
}
*/
