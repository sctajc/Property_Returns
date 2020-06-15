import 'package:flutter/material.dart';
import 'package:property_returns/models/company_details.dart';
import 'package:property_returns/screens/contacts/add_company.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/shared/loading.dart';
import 'company_tile.dart';

class CompanyList extends StatefulWidget {
  static String id = 'company_list_screen';

  @override
  _CompanyListState createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    // TODO is this a good approach??
    // Used <List<TasksDetails> StreamBuilder here as own list order
    return StreamBuilder<List<CompanyDetails>>(
        stream: DatabaseServices(uid: user.userUid).userCompanies,
        builder: (context, allUserCompanies) {
          if (!allUserCompanies.hasData) return Loading();
          return Scaffold(
            appBar: AppBar(
              title: Text('Contacts'),
              actions: <Widget>[
                FlatButton.icon(
                  onPressed: () => null,
                  icon: Icon(Icons.search),
                  label: Text(''),
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
                                "If you wish to revisit companies which have been archived go back to main menu and select 'Companies archived'.",
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
