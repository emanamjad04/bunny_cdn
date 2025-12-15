import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
class ShopWeb extends StatefulWidget {
  final String Url;
  final String title;
  final String Code;
  final String logoUrl;
  const ShopWeb({ required this.title,required this.logoUrl,required this.Code,required this.Url,super.key});

  @override
  State<ShopWeb> createState() => _ShopWebState();
}

class _ShopWebState extends State<ShopWeb> {
  InAppWebViewController? _controller;
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
  title: Row(
    children: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: CircleAvatar(

            child: CachedNetworkImage(
              imageUrl: widget.logoUrl,
              fit: BoxFit.cover,

            ),
          )
        ),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF444444),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.Code.isNotEmpty)
              Text(
                widget.Code,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF444444),
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
        IconButton(onPressed:(){
          widget.Code.split(' ').last.copy;
        } , icon:      Icon(Icons.copy_rounded,size: 20,
          color: Color(0xFF444444),
        )),


    ],
  ),
  leading: IconButton(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: const Icon(Icons.close_outlined,
      color: Color(0xFF444444),

    ),
  ),
),
      body: InAppWebView(
        onWebViewCreated: (controller) {
          _controller = controller;
        },
        initialUrlRequest: URLRequest(url: WebUri(widget.Url)),
      ),
    );
  }

}

extension on String {
  get copy => Clipboard.setData(ClipboardData(text: this)).then(
        (value) => Fluttertoast.showToast(
      msg: 'Copied to clipboard',
      // msg: 'Discount code "$code" copied!',
      gravity: ToastGravity.TOP,
    ),
  );
}
