import 'package:get/get.dart';
import '../views/login_view.dart';
import '../views/home_view.dart';
import '../views/detail_view.dart';
import '../views/create_edit_view.dart';
import '../views/otp_view.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
    ),
    GetPage(
      name: Routes.OTP,
      page: () => const OtpView(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
    ),
    GetPage(
      name: Routes.DETAIL,
      page: () => const DetailView(),
    ),
    GetPage(
      name: Routes.CREATE,
      page: () => const CreateEditView(),
    ),
    GetPage(
      name: Routes.EDIT,
      page: () => const CreateEditView(),
    ),
  ];
}

abstract class Routes {
  static const LOGIN = '/login';
  static const OTP = '/otp';
  static const HOME = '/home';
  static const DETAIL = '/detail';
  static const CREATE = '/create';
  static const EDIT = '/edit';
}
