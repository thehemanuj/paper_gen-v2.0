import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paper_gen/ProviderData/AuthorisationData.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';
import 'package:provider/provider.dart';

class MyContainer extends StatelessWidget {
  const MyContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
              color: Color(0xff26a69a), width: 3, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(20.0)),
      // REMOVED Expanded - Container doesn't need Expanded as a child
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Added this
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Added ClipRRect for circular avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(37.5),
                  child: SvgPicture.string(
                    Provider.of<QuestionData>(context).getImage(),
                    height: 75.0,
                    width: 75.0,
                    fit: BoxFit.cover, // Added fit
                  ),
                ),
                SizedBox(width: 20.0),
                Expanded(
                  // Added Expanded here to prevent overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${Provider.of<AuthorisationData>(context).fn} ${Provider.of<AuthorisationData>(context).ln}',
                        style: TextStyle(
                            color: Color(0xff26a69a),
                            fontFamily: 'Copper',
                            fontSize: 30.0),
                        overflow:
                            TextOverflow.ellipsis, // Added overflow handling
                      ),
                      Text(
                        Provider.of<AuthorisationData>(context).email,
                        style: TextStyle(
                            color: Color(0xff26a69a),
                            fontFamily: 'Copper',
                            fontSize: 15.0),
                        overflow:
                            TextOverflow.ellipsis, // Added overflow handling
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Divider(
              color: Provider.of<ProgressData>(context).darkMode
                  ? Colors.white54
                  : Colors.grey,
              height: 2.0,
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              width: MediaQuery.widthOf(context),
              decoration: BoxDecoration(
                  color: Color(0xff36d0c2),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 15.0,
                  ),
                  Text("Edit"),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
