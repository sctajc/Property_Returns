import 'package:flutter/material.dart';
import 'package:property_returns/models/company_details.dart';
import 'package:property_returns/screens/contacts/add_company.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:property_returns/screens/contacts/company_tile.dart';

enum DisplayOrder {
  tasks,
  properties,
  units,
  leases,
}

class ArchivedList extends StatefulWidget {
  static String id = 'archived_list_screen';

  @override
  _ArchivedListState createState() => _ArchivedListState();
}

class _ArchivedListState extends State<ArchivedList> {
  DisplayOrder _displayOrder = DisplayOrder.tasks;
  var _databaseServicesDisplayOrder;
  String _displayLabel = 'Tasks';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    switch (_displayOrder) {
      case DisplayOrder.tasks:
        _databaseServicesDisplayOrder =
            DatabaseServices(uid: user.userUid).userCompaniesAll;
        break;
      case DisplayOrder.properties:
        _databaseServicesDisplayOrder =
            DatabaseServices(uid: user.userUid).userCompaniesTenants;
        break;
      case DisplayOrder.units:
        _databaseServicesDisplayOrder =
            DatabaseServices(uid: user.userUid).userCompaniesTrades;
        break;
      case DisplayOrder.leases:
        _databaseServicesDisplayOrder =
            DatabaseServices(uid: user.userUid).userCompaniesAgents;
        break;
    }

    // TODO is this a good approach??
    // Used <List<TasksDetails> StreamBuilder here as own list order
    return StreamBuilder<List<CompanyDetails>>(
        stream:
            _databaseServicesDisplayOrder, // DatabaseServices(uid: user.userUid).userCompaniesAll,
        builder: (context, allUserCompanies) {
          if (!allUserCompanies.hasData) return Loading();
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Archived',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(_displayLabel),
                  onPressed: () {
                    setState(
                      () {
                        switch (_displayOrder) {
                          case DisplayOrder.tasks:
                            _displayOrder = DisplayOrder.properties;
                            _displayLabel = 'Tasks';
                            break;
                          case DisplayOrder.properties:
                            _displayOrder = DisplayOrder.units;
                            _displayLabel = 'Properties';
                            break;
                          case DisplayOrder.units:
                            _displayOrder = DisplayOrder.leases;
                            _displayLabel = 'Units';
                            break;
                          case DisplayOrder.leases:
                            _displayOrder = DisplayOrder.tasks;
                            _displayLabel = 'Leases';
                            break;
                        }
                      },
                    );
                  },
                ),
                showCompanyAppBarHelp(context),
              ],
            ),
            body: Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: allUserCompanies.data.length > 0
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: allUserCompanies.data.length,
                        itemBuilder: (context, index) {
                          return CompanyTile(
                              companyDetails: allUserCompanies.data[index]);
                        },
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 30),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "Contacts will mostly be companies. But can be any organisation. "
                                "Either you have not entered any contacts or they have been archived. "
                                "Use the 'plus' button below right to add contacts. "
                                "If you wish to revisit companies which have been archived go "
                                "back to main menu and select 'Companies archived'.",
                                style: TextStyle(
                                    color: kColorOrange, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
              ),
              onPressed: () => Navigator.pushNamed(context, AddCompany.id),
            ),
          );
        });
  }

  showCompanyAppBarHelp(BuildContext context) {
    return FlatButton.icon(
      onPressed: () => kShowHelpToast(
          context,
          // TODO should be able to display icons here??
          'Select whatever to un archive. '
          'Should be possible. '),
      icon: Icon(Icons.help),
      label: Text('Help'),
    );
  }
}
