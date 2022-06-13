import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:masterstudy_app/data/models/category.dart';
import 'package:masterstudy_app/data/models/course/CourcesResponse.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/screens/category_detail/category_detail_screen.dart';
import 'package:masterstudy_app/ui/screens/course/course_screen.dart';

import '../../../../main.dart';

class TrendingWidget extends StatefulWidget {
  final bool darkMode;
  final String? title;
  final List<CoursesBean?> courses;

  TrendingWidget(this.darkMode, this.title, this.courses, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TrendingWidget();
}

class _TrendingWidget extends State<TrendingWidget> {
  var backgroundColor;
  var primaryTextColor;
  var secondaryTextColor;

  @override
  Widget build(BuildContext context) {
    backgroundColor = widget.darkMode ? dark : Colors.white;
    primaryTextColor = widget.darkMode ? white : dark;
    secondaryTextColor = widget.darkMode ? white.withOpacity(0.5) : Colors.grey[500];

    return (widget.courses.length != 0)
        ? Container(
            decoration: BoxDecoration(color: backgroundColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(top: 30.0, left: 30.0, bottom: 20),
                    child: Text(localizations!.getLocalization("trending_courses"), textScaleFactor: 1.0, style: Theme.of(context).primaryTextTheme.headline6?.copyWith(color: primaryTextColor, fontStyle: FontStyle.normal))),
                _buildList(context)
              ],
            ),
          )
        : Center();
  }

  _buildList(context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
          itemCount: widget.courses.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            double leftPadding = (index == 0) ? 30 : 8;
            var item = widget.courses[index];
            num? rating = 0.0;
            num? reviews = 0;
            if (item?.rating?.total != null) {
              rating = item?.rating?.average?.toDouble();
            }
            if (item?.rating?.total != null) {
              reviews = item?.rating?.total;
            }
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  CourseScreen.routeName,
                  arguments: CourseScreenArgs.fromCourseBean(item!),
                );
              },
              child: Padding(
                  padding: EdgeInsets.only(left: leftPadding),
                  child: _buildItem(
                    context,
                    item?.images?.small,
                    item?.categories_object,
                    "${item?.title}",
                    rating,
                    reviews,
                    item?.price?.price,
                    item?.price?.old_price,
                    item?.price?.free,
                  )),
            );
          }),
    );
  }

  _buildItem(context, image, List<Category?>? category, title, stars, reviews, price, oldPrice, free) {
    var unescape = new HtmlUnescape();

    String categoryName = (category != null && category.isNotEmpty) ? "${unescape.convert(category.first?.name)} >" : "";
    return SizedBox(
      width: 170,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 160,
              height: 80,
              child: Image.network(
                image,
                fit: BoxFit.cover,
                width: 160,
                height: 80,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 0.0, right: 16.0),
              child: GestureDetector(
                  onTap: () {
                    if (category != null && category.isNotEmpty)
                      Navigator.pushNamed(
                        context,
                        CategoryDetailScreen.routeName,
                        arguments: CategoryDetailScreenArgs(category.first),
                      );
                  },
                  child: Text(
                    categoryName,
                    textScaleFactor: 1.0,
                    style: Theme.of(context).primaryTextTheme.subtitle1?.copyWith(color: secondaryTextColor, fontStyle: FontStyle.normal, fontSize: 12),
                  )),
            ),
            Container(
              height: 32,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 0.0, right: 16.0),
                child: Text(
                  unescape.convert(title),
                  textScaleFactor: 1.0,
                  maxLines: 2,
                  style: Theme.of(context).primaryTextTheme.subtitle1?.copyWith(color: primaryTextColor, fontStyle: FontStyle.normal, fontSize: 12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 0.0, right: 16.0),
              child: Row(
                children: <Widget>[
                  RatingBar(
                    initialRating: stars,
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 16,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    glow: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      "$stars ($reviews)",
                      textScaleFactor: 1.0,
                      style: TextStyle(fontSize: 16, color: primaryTextColor),
                    ),
                  ),
                ],
              ),
            ),
            _buildPrice(price, oldPrice, free)
          ],
        ),
      ),
    );
  }

  _buildPrice(price, oldPrice, free) {
    if (free)
      return Text(
        localizations!.getLocalization("course_free_price"),
        textScaleFactor: 1.0,
        style: Theme.of(context).primaryTextTheme.subtitle1?.copyWith(color: primaryTextColor, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
      );
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 0.0, right: 16.0),
      child: Row(
        children: <Widget>[
          Text(
            price,
            textScaleFactor: 1.0,
            style: Theme.of(context).primaryTextTheme.subtitle1?.copyWith(color: primaryTextColor, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
          ),
          Visibility(
            visible: oldPrice != null,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                oldPrice.toString(),
                textScaleFactor: 1.0,
                style: Theme.of(context).primaryTextTheme.subtitle1?.copyWith(color: secondaryTextColor, fontStyle: FontStyle.normal, decoration: TextDecoration.lineThrough),
              ),
            ),
          )
        ],
      ),
    );
  }
}
