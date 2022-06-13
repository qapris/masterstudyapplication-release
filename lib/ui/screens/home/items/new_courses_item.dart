import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:masterstudy_app/data/models/category.dart';
import 'package:masterstudy_app/data/models/course/CourcesResponse.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/screens/category_detail/category_detail_screen.dart';
import 'package:masterstudy_app/ui/screens/course/course_screen.dart';

import '../../../../main.dart';

class NewCoursesWidget extends StatelessWidget {
  final String? title;
  final List<CoursesBean?> courses;

  NewCoursesWidget(this.title, this.courses, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (courses.length != 0)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 30.0, bottom: 20),
                child: Text(
                  localizations!.getLocalization("new_courses"),
                  textScaleFactor: 1.0,
                  style: Theme.of(context).primaryTextTheme.headline6?.copyWith(color: dark, fontStyle: FontStyle.normal),
                ),
              ),
              _buildList(context)
            ],
          )
        : SizedBox();
  }

  _buildList(context) {
    return Container(
      decoration: BoxDecoration(color: HexColor.fromHex("#eef1f7")),
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20),
        child: ConstrainedBox(
          constraints: new BoxConstraints(minHeight: 370, maxHeight: 390),
          child: new ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              var item = courses[index];
              var padding = (index == 0) ? 20.0 : 0.0;

              double? rating = 0.0;
              num? reviews = 0;
              rating = item?.rating?.average?.toDouble();
              reviews = item?.rating?.total;
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    CourseScreen.routeName,
                    arguments: CourseScreenArgs.fromCourseBean(item!),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(left: padding),
                  child: _buildCard(context, item?.images?.small, item?.categories_object.first, "${item?.title}", rating, reviews, item?.price?.price, item?.price?.old_price, item?.price?.free),
                ),
              );
            },
            padding: const EdgeInsets.all(8.0),
            scrollDirection: Axis.horizontal,
          ),
        ),
      ),
    );
  }

  _buildCard(context, image, Category? category, title, stars, reviews, price, oldPrice, free) {
    var unescape = new HtmlUnescape();
    String categoryName = category != null ? "${unescape.convert(category.name)} >" : "";
    return SizedBox(
      width: 300,
      child: Card(
        borderOnForeground: true,
        elevation: 3,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.network(
                image,
                width: 320,
                height: 160,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      CategoryDetailScreen.routeName,
                      arguments: CategoryDetailScreenArgs(category),
                    );
                  },
                  child: Text(
                    categoryName,
                    textScaleFactor: 1.0,
                    style: TextStyle(fontSize: 18, color: HexColor.fromHex("#2a3045").withOpacity(0.5)),
                  ),
                ),
              ),
              Container(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0, left: 16.0, right: 16.0),
                  child: Text(
                    unescape.convert(title),
                    textScaleFactor: 1.0,
                    maxLines: 2,
                    style: TextStyle(fontSize: 22, color: dark),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: Divider(
                  color: HexColor.fromHex("#e0e0e0"),
                  thickness: 1.3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 15.0, right: 16.0),
                child: Row(
                  children: <Widget>[
                    RatingBar(
                      initialRating: stars,
                      minRating: 0,
                      direction: Axis.horizontal,
                      tapOnlyMode: true,
                      glow: false,
                      allowHalfRating: true,
                      ignoreGestures: true,
                      itemCount: 5,
                      itemSize: 19,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "${stars} (${reviews})",
                        textScaleFactor: 1.0,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              _buildPrice(context, price, oldPrice, free)
            ],
          ),
        ),
      ),
    );
  }

  _buildPrice(context, price, oldPrice, free) {
    if (free)
      return Padding(
        padding: const EdgeInsets.only(left: 18.0),
        child: Text(
          localizations!.getLocalization("course_free_price"),
          textScaleFactor: 1.0,
          style: Theme.of(context).primaryTextTheme.headline5?.copyWith(color: dark, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
        ),
      );
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          Text(
            price,
            textScaleFactor: 1.0,
            style: Theme.of(context).primaryTextTheme.headline5?.copyWith(color: dark, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
          ),
          Visibility(
            visible: oldPrice != null,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                oldPrice.toString(),
                textScaleFactor: 1.0,
                style: Theme.of(context).primaryTextTheme.headline5?.copyWith(color: HexColor.fromHex("#999999"), fontStyle: FontStyle.normal, decoration: TextDecoration.lineThrough),
              ),
            ),
          )
        ],
      ),
    );
  }
}
