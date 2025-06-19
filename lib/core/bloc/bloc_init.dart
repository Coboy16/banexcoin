import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: depend_on_referenced_packages
import 'package:provider/single_child_widget.dart';

import '/core/bloc/blocs.dart';

List<SingleChildWidget> getListBloc() {
  return [
    BlocProvider(
      create: (context) => ThemeBloc()..add(const InitializeThemeEvent()),
    ),
    BlocProvider(create: (context) => NavigationBloc()),
  ];
}
