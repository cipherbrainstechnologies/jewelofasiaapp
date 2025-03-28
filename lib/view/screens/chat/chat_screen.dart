import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grocery/data/model/response/order_model.dart';
import 'package:flutter_grocery/helper/notification_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/chat_provider.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/not_login_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/chat/widget/message_bubble.dart';
import 'package:flutter_grocery/view/screens/chat/widget/message_bubble_shimmer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final bool isAppBar;
  const ChatScreen({Key? key,required this.orderModel, this.isAppBar = false}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputMessageController = TextEditingController();
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  late bool _isLoggedIn;
  bool _isFirst = true;

  var androidInitialize = const AndroidInitializationSettings('notification_icon.png');
  var iOSInitialize = const DarwinInitializationSettings();


  @override
  void initState() {
    super.initState();

    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin!.initialize(initializationsSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if(!kIsWeb){
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
      }

      Provider.of<ChatProvider>(context, listen: false).getMessages(1, widget.orderModel, false);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Provider.of<ChatProvider>(context, listen: false).getMessages(1, widget.orderModel, false);
    });

    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();


    if(_isLoggedIn){
      if(_isFirst) {

        Provider.of<ChatProvider>(context, listen: false).getMessages(1, widget.orderModel, true);
      }else {
        Provider.of<ChatProvider>(context, listen: false).getMessages(1, widget.orderModel, false);
        _isFirst = false;
      }
      Provider.of<ProfileProvider>(context, listen: false).getUserInfo();
    }

  }

  @override
  void dispose() {
    flutterLocalNotificationsPlugin!.cancelAll();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //
    final bool isAdmin = widget.orderModel == null ? true : false;
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar())
          : ResponsiveHelper.isMobilePhone() && isAdmin && !widget.isAppBar ? null : AppBar(title: isAdmin ? Text('${Provider.of<SplashProvider>(context,listen: false).configModel!.ecommerceName}')
          : Text('${widget.orderModel!.deliveryMan!.fName!} ${widget.orderModel!.deliveryMan!.lName!}'),backgroundColor: Theme.of(context).primaryColor,
          actions: <Widget>[
            Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(width: 40,height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 2,color: Theme.of(context).cardColor),
                  color: Theme.of(context).cardColor),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: FadeInImage.assetNetwork(
                  fit: BoxFit.cover,
                  placeholder: isAdmin ? Images.appLogo : Images.profilePlaceholder,
                  image: isAdmin ? '' : '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.deliveryManImageUrl}/${widget.orderModel!.deliveryMan!.image}',
                  imageErrorBuilder: (c,t,o) => Image.asset(isAdmin ? Images.appLogo : Images.profilePlaceholder,fit: BoxFit.cover,),
                ),
              ),
            ),
          )
          ])  ,

      body: _isLoggedIn? Center(
        child: SizedBox(
          width: ResponsiveHelper.isDesktop(context) ?1170:MediaQuery.of(context).size.width,
          child: Column(
            children: [

              Consumer<ChatProvider>(
                  builder: (context, chatProvider,child) {
                    return chatProvider.messageList == null ?  Expanded(child: ListView.builder(
                        reverse: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: 15,
                        itemBuilder: (context, index)=> MessageBubbleShimmer(isMe: index.isOdd),
                    )) : Expanded(
                      child: ListView.builder(
                          reverse: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: chatProvider.messageList!.length,
                          itemBuilder: (context, index){
                            return MessageBubble(messages: chatProvider.messageList![index], isAdmin: isAdmin);
                          }),
                    );
                  }
              ),

              Container(
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    Consumer<ChatProvider>(
                        builder: (context, chatProvider,_) {
                          return chatProvider.chatImage!.isNotEmpty?
                          SizedBox(height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: chatProvider.chatImage!.length,
                              itemBuilder: (BuildContext context, index){
                                return  chatProvider.chatImage!.isNotEmpty?
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      Container(width: 100, height: 100,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                          child: ResponsiveHelper.isWeb()? Image.network(chatProvider.chatImage![index].path, width: 100, height: 100,
                                            fit: BoxFit.cover,
                                          ):Image.file(File(chatProvider.chatImage![index].path), width: 100, height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ) ,
                                      ),
                                      Positioned(
                                        top:0,right:0,
                                        child: InkWell(
                                          onTap :() => chatProvider.removeImage(index),
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(Icons.clear,color: Colors.red,size: 15,),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ):const SizedBox();

                              },),
                          ):const SizedBox();
                        }
                    ),
                    Row(children: [
                      InkWell(
                        onTap: () async {
                          Provider.of<ChatProvider>(context, listen: false).pickImage(false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          child: Image.asset(Images.image, width: 25, height: 25, color: Theme.of(context).hintColor),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                        child: VerticalDivider(width: 0, thickness: 1, color: Theme.of(context).hintColor),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.2),
                          child: TextField(
                            inputFormatters: [LengthLimitingTextInputFormatter(Dimensions.messageInputLength)],
                            controller: _inputMessageController,
                            textCapitalization: TextCapitalization.sentences,
                            style: poppinsRegular,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Type here',
                              hintStyle: poppinsRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge),
                            ),
                            onSubmitted: (String newText) {
                              if(newText.trim().isNotEmpty && !Provider.of<ChatProvider>(context, listen: false).isSendButtonActive) {
                                Provider.of<ChatProvider>(context, listen: false).toggleSendButtonActivity();
                              }else if(newText.isEmpty && Provider.of<ChatProvider>(context, listen: false).isSendButtonActive) {
                                Provider.of<ChatProvider>(context, listen: false).toggleSendButtonActivity();
                              }
                            },
                            onChanged: (String newText) {
                              if(newText.trim().isNotEmpty && !Provider.of<ChatProvider>(context, listen: false).isSendButtonActive) {
                                Provider.of<ChatProvider>(context, listen: false).toggleSendButtonActivity();
                              }else if(newText.isEmpty && Provider.of<ChatProvider>(context, listen: false).isSendButtonActive) {
                                Provider.of<ChatProvider>(context, listen: false).toggleSendButtonActivity();
                              }
                            },

                          ),
                        ),
                      ),




                      InkWell(
                        onTap: () async {
                          if(Provider.of<ChatProvider>(context, listen: false).isSendButtonActive){
                              Provider.of<ChatProvider>(context, listen: false).sendMessage(_inputMessageController.text, context, Provider.of<AuthProvider>(context, listen: false).getUserToken(), widget.orderModel);
                              _inputMessageController.clear();
                            Provider.of<ChatProvider>(context, listen: false).toggleSendButtonActivity();

                          }else{
                            showCustomSnackBar('write_somethings');
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          child: Provider.of<ChatProvider>(context, listen: false).isLoading ? SizedBox(
                            width: 25, height: 25,
                            child: CustomLoader(color: Theme.of(context).primaryColor),
                          ) : Image.asset(Images.send, width: 25, height: 25,
                            color: Provider.of<ChatProvider>(context).isSendButtonActive ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                          ),
                        ),
                      ),

                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ):const NotLoggedInScreen(),
    );
  }
}
