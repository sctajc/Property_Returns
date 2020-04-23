import 'package:flutter/material.dart';
import 'package:property_returns/screens/properties/add_property.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/screens/properties/property_tile.dart';
import 'package:property_returns/shared/loading.dart';

class PropertyList extends StatefulWidget {
  static String id = 'property_list_screen';

  @override
  _PropertyListState createState() => _PropertyListState();
}

class _PropertyListState extends State<PropertyList> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    // TODO is this a good approach??
    // Used <List<TasksDetails> StreamBuilder here as own list order
    return StreamBuilder<List<PropertyDetails>>(
        stream: DatabaseServices(uid: user.userUid).userProperties,
        builder: (context, allUserProperties) {
          if (!allUserProperties.hasData) return Loading();
          return Scaffold(
            appBar: AppBar(
              title: Text('Properties'),
              actions: <Widget>[
                FlatButton.icon(
                  onPressed: () => null,
                  icon: Icon(Icons.search),
                  label: Text(''),
                ),
                FlatButton.icon(
                  onPressed: () => kShowHelpToast(
                      context,
                      'A unit is a defined area within a property available for individual renting. '
                      ' Property may be let as one single unit, or may contain many lettable areas.'),
                  icon: Icon(Icons.help),
                  label: Text('Help'),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: allUserProperties.data.length > 0
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: allUserProperties.data.length,
                      itemBuilder: (context, index) {
                        return PropertyTile(
                            propertyDetails: allUserProperties.data[index]);
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 30),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Either you have not entered any properties or all your properties have been archived. "
                              "Use the 'plus' button below right to add properties. "
                              "If you wish to revisit properties which have been archived go back to main menu and select 'Properties archived' near the bottom",
                              style:
                                  TextStyle(color: kColorOrange, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
              ),
              onPressed: () => Navigator.pushNamed(context, AddProperty.id),
            ),
          );
        });
  }
}
