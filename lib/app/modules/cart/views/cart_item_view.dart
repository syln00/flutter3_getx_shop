/*
 * @ Author: kiko
 * @ Create Time: 2024-03-26 06:34:32
 * @ Modified by: kiko
 * @ Modified time: 2024-03-29 04:01:47
 * @ Description:
 */

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../units/screenAdapter.dart';
import '../controllers/cart_controller.dart';
import '../views/cart_item_mun_view.dart';
import '../../../units/httpsClient.dart';

class CartItemView extends GetView {
  @override
  final CartController controller = Get.find();
  final Map cartItem;
  CartItemView(this.cartItem, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenAdapter.height(20)),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(          
                    color: const Color.fromARGB(178, 240, 236, 236),
                    width: ScreenAdapter.height(2))),
          ),
      child: Row(
        children: [
          SizedBox(
            width: ScreenAdapter.width(100),
            child: Checkbox(
                activeColor: Colors.red, 
                value: cartItem["checked"], 
                onChanged: (value) {
                  controller.checkCartItem(cartItem);
                }),
          ),
          Container(
            width: ScreenAdapter.width(260),
            padding: EdgeInsets.all(ScreenAdapter.height(24)),
            margin: EdgeInsets.only(right: ScreenAdapter.width(20)),
            child: Image.network(HttpsClient.replaeUri(cartItem["pic"]),
                fit: BoxFit.fitHeight),
          ),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${cartItem["title"]}",
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(36),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: ScreenAdapter.height(20)),
              Row(
                children: [Chip(label: Text("${cartItem["selectedAttr"]}"))],
              ),
              SizedBox(height: ScreenAdapter.height(20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("¥${cartItem["price"]}",
                      style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(38),
                          color: Colors.red)),
                  CartItemMunView(cartItem)
                ],
              )
            ],
          ))
        ],
      ),
    );
  }
}
