import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:profile_viewer/provider/listFilterProvider.dart';
import 'package:profile_viewer/provider/profileFilterProvider.dart';
import 'package:provider/provider.dart';

Widget filterForm(ProfileFilterProvider data, GlobalKey<FormBuilderState> _categoryFormKey, BuildContext context) {
  return FormBuilder(
    key: _categoryFormKey,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          FormBuilderFilterChip(
            name: 'filter',
            disabledColor: Colors.white,
            selectedColor: Colors.blue.shade200,
            selectedShadowColor: Colors.blueGrey,
            spacing: MediaQuery.of(context).size.width / 1.8,
            onChanged: (v) {
              if (_categoryFormKey.currentState != null &&
                  _categoryFormKey.currentState!.fields['filter'] != null) {
                context.read<ProfileFilterProvider>().setFilterStatus(true);
                List<String> type =
                    _categoryFormKey.currentState!.fields['filter']!.value;
                context.read<ProfileFilterProvider>().setFilterBy(type);
                if (!type.contains('Age'))
                  context
                      .read<ListFilterProvider>()
                      .setAgeLimit(RangeValues(18, 60));
                if (!type.contains('Interest'))
                  context.read<ListFilterProvider>().setInterest('');
              }
            },
            decoration: InputDecoration(
              labelText: 'Filter By',
              labelStyle: TextStyle(
                color: Color(0xFF020663),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            options: [
              FormBuilderFieldOption(
                value: 'Age',
                child: Text('Age'),
              ),
              FormBuilderFieldOption(
                value: 'Interest',
                child: Text('Interest'),
              ),
            ],
          ),
          if (data.getFilterStatus)
            if (data.getFilterBy.contains('Interest'))
              FormBuilderChoiceChip(
                name: 'interests',
                disabledColor: Colors.white,
                selectedColor: Colors.blue.shade200,
                selectedShadowColor: Colors.blueGrey,
                labelStyle: TextStyle(color: Colors.black),
                onChanged: (v) {
                  String value;
                  (v != null) ? value = v.toString() : value = '';
                  context.read<ListFilterProvider>().setInterest(value);
                },
                spacing: MediaQuery.of(context).size.width / 5,
                decoration: InputDecoration(
                  labelText: 'Interests By',
                  labelStyle: TextStyle(
                    color: Color(0xFF020663),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                options: [
                  FormBuilderFieldOption(
                    value: 'one',
                    child: Text('Type A'),
                  ),
                  FormBuilderFieldOption(
                    value: 'two',
                    child: Text('Type B'),
                  ),
                  FormBuilderFieldOption(
                    value: 'three',
                    child: Text('Type C'),
                  ),
                ],
              ),
          if (data.getFilterStatus)
            if (data.getFilterBy.contains('Age'))
              FormBuilderRangeSlider(
                name: 'age',
                onChanged: (v) {
                  context.read<ListFilterProvider>().setAgeLimit(v!);
                },
                min: 18,
                max: 60,
                initialValue: RangeValues(18, 60),
                divisions: 21,
                activeColor: Colors.red,
                inactiveColor: Colors.pink[100],
                decoration: const InputDecoration(
                  labelText: 'Age Limit',
                  labelStyle: TextStyle(
                    color: Color(0xFF020663),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
        ],
      ),
    ),
  );
}