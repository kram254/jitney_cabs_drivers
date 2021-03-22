import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:jitney_cabs_driver/src/tabPages/earningsTab.dart';
import 'package:jitney_cabs_driver/src/tabPages/homeTab.dart';
import 'package:jitney_cabs_driver/src/tabPages/profileTab.dart';
import 'package:jitney_cabs_driver/src/tabPages/ratingsTab.dart';

class HomeScreen extends StatefulWidget {
  static const String idScreen = "homeScreen";
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin
 {

  TabController tabController;
  int selectedIndex = 0;

  void onItemClicked(int index)
  {
    setState(() {
          selectedIndex = index;
          tabController.index = selectedIndex;
        });
  }

  @override
    void initState() {
      // TODO: implement initState
      super.initState();

      tabController = TabController(length: 4, vsync: this);
    }

    @override
      void dispose() {
        // TODO: implement dispose
        super.dispose();
        tabController.dispose();

      }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTab(),
          RatingsTab(),
          EarningsTab(),
          ProfileTab(),

        ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>
          [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_outlined),
              label: "Earnings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline_sharp),
              label: "Rating",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Account",
            ),
          ],
         
         unselectedItemColor: black,
         selectedItemColor: orange,
         type: BottomNavigationBarType.fixed,
         selectedLabelStyle: TextStyle(fontSize: 13.0),
         showUnselectedLabels: true,
         currentIndex: selectedIndex,
         onTap: onItemClicked,
          ),
      
    );
  }
}