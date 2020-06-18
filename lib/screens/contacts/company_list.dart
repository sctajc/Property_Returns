import 'package:flutter/material.dart';
import 'package:property_returns/models/company_details.dart';
import 'package:property_returns/screens/contacts/add_company.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/shared/loading.dart';
import 'company_tile.dart';

enum DisplayOrder {
  all,
  tenants,
  trades,
  agents,
}

class CompanyList extends StatefulWidget {
  static String id = 'company_list_screen';

  @override
  _CompanyListState createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {
  DisplayOrder _displayOrder = DisplayOrder.all;
  var _databaseServicesDisplayOrder;
  String _displayLabel = 'All';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    switch (_displayOrder) {
      case DisplayOrder.all:
        _databaseServicesDisplayOrder =
            DatabaseServices(uid: user.userUid).userCompaniesAll;
        break;
      case DisplayOrder.tenants:
        _databaseServicesDisplayOrder =
            DatabaseServices(uid: user.userUid).userCompaniesTenants;
        break;
      case DisplayOrder.trades:
        _databaseServicesDisplayOrder =
            DatabaseServices(uid: user.userUid).userCompaniesTrades;
        break;
      case DisplayOrder.agents:
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
              title: Text('Contacts'),
              actions: <Widget>[
                FlatButton(
                  child: Text(_displayLabel),
                  onPressed: () {
                    setState(
                      () {
                        switch (_displayOrder) {
                          case DisplayOrder.all:
                            _displayOrder = DisplayOrder.tenants;
                            _displayLabel = 'Tenants';
                            break;
                          case DisplayOrder.tenants:
                            _displayOrder = DisplayOrder.trades;
                            _displayLabel = 'Trades';
                            break;
                          case DisplayOrder.trades:
                            _displayOrder = DisplayOrder.agents;
                            _displayLabel = 'Agents';
                            break;
                          case DisplayOrder.agents:
                            _displayOrder = DisplayOrder.all;
                            _displayLabel = 'All';
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
          'A company could be any organisation. Long press icons to see phone number and email address. '
          'Short press icons to phone or email. '),
      icon: Icon(Icons.help),
      label: Text('Help'),
    );
  }
}
