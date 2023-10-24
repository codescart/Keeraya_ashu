import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';
import '../widgets/membership_plan_item.dart';

class MembershipPlanScreen extends StatelessWidget {
  static const routeName = '/membership-plans';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final langPack = Provider.of<Languages>(context).selected;
    final apiHelper = Provider.of<APIHelper>(context);
    final appBar = AppBar(
      title: Text(
        langPack['Premium Membership'],
        textDirection: CurrentUser.textDirection,
        style: TextStyle(
          color: Colors.grey[800],
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.grey[800],
      iconTheme: IconThemeData(
        color: Colors.grey[800],
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: FutureBuilder(
        future: apiHelper.fetchMembershipPlan(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: [
              CarouselSlider(
                items: List.generate(snapshot.data.length, (i) {
                  var membership = snapshot.data[i];
                  return MembershipPlanWidget(
                    id: membership.id,
                    title: membership.title,
                    price: membership.price,
                    term: membership.term,
                    postLimit: membership.limit,
                    adDuration: membership.duration,
                    featuredFee: membership.featuredFee,
                    urgentFee: membership.urgentFee,
                    highlightFee: membership.highlightFee,
                    featuredDuration: membership.featuredDuration,
                    urgentDuration: membership.urgentDuration,
                    highlightDuration: membership.highlightDuration,
                    topInSearchAndCategory: membership.topSearchResult,
                    showOnHome: membership.showOnHome,
                    showInHomeSearch: membership.showInHomeSearch,
                  );
                }),
                options: CarouselOptions(
                  viewportFraction: 0.9,
                  aspectRatio: size.height > 1000 ? 1 : 0.7,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [0, 1].map((url) {
                  return Container(
                    width: 15.0,
                    height: 15.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
